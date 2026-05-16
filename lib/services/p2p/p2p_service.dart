import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/entities.dart';
import 'android_p2p_service.dart';
import 'desktop_p2p_service.dart';
import 'web_p2p_service.dart';

// ── P2P Protocol Constants ───────────────────────────────────────────────────

class P2PProtocol {
  static const servicePort = 45678;
  static const discoveryPort = 45679;
  static const chunkSize = 64 * 1024; // 64 KB per chunk
  static const broadcastAddress = '255.255.255.255';
  static const serviceTag = 'LEARNGRID_P2P_V1';
}

// ── Events ────────────────────────────────────────────────────────────────────

enum P2PEventType {
  peerDiscovered,
  peerLost,
  connectionRequested,
  connected,
  disconnected,
  transferStarted,
  transferProgress,
  transferComplete,
  transferFailed,
  error,
}

class P2PEvent {
  final P2PEventType type;
  final String? peerId;
  final String? peerName;
  final String? contentId;
  final double? progress; // 0.0 – 1.0
  final String? errorMessage;
  final ContentItemEntity? receivedContent;
  final Uint8List? fileBytes;

  const P2PEvent({
    required this.type,
    this.peerId,
    this.peerName,
    this.contentId,
    this.progress,
    this.errorMessage,
    this.receivedContent,
    this.fileBytes,
  });
}

// ── Peer ──────────────────────────────────────────────────────────────────────

class DiscoveredPeer {
  final String id;
  final String name;
  final String address;
  final int port;
  final DateTime seenAt;

  DiscoveredPeer({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required DateTime? seenAt,
  }) : seenAt = seenAt ?? DateTime.now();
}

// ── Chunk packet ──────────────────────────────────────────────────────────────

class ChunkPacket {
  final String contentId;
  final int chunkIndex;
  final int totalChunks;
  final String contentType;
  final String contentTitle;
  final String sha256;      // of entire reassembled file
  final Uint8List payload;

  ChunkPacket({
    required this.contentId,
    required this.chunkIndex,
    required this.totalChunks,
    required this.contentType,
    required this.contentTitle,
    required this.sha256,
    required this.payload,
  });

  Uint8List toBytes() {
    final header = jsonEncode({
      'contentId': contentId,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'contentType': contentType,
      'contentTitle': contentTitle,
      'sha256': sha256,
    });
    final headerBytes = utf8.encode(header);
    final bb = ByteData(4 + headerBytes.length + payload.length);
    bb.setUint32(0, headerBytes.length, Endian.big);
    for (int i = 0; i < headerBytes.length; i++) {
      bb.setUint8(4 + i, headerBytes[i]);
    }
    for (int i = 0; i < payload.length; i++) {
      bb.setUint8(4 + headerBytes.length + i, payload[i]);
    }
    return bb.buffer.asUint8List();
  }

  static ChunkPacket fromBytes(Uint8List data) {
    final headerLen = ByteData.sublistView(data, 0, 4).getUint32(0, Endian.big);
    final headerJson =
        utf8.decode(data.sublist(4, 4 + headerLen));
    final header = jsonDecode(headerJson) as Map<String, dynamic>;
    final payload = data.sublist(4 + headerLen);
    return ChunkPacket(
      contentId: header['contentId'] as String,
      chunkIndex: header['chunkIndex'] as int,
      totalChunks: header['totalChunks'] as int,
      contentType: header['contentType'] as String,
      contentTitle: header['contentTitle'] as String,
      sha256: header['sha256'] as String,
      payload: payload,
    );
  }
}

// ── Interface ─────────────────────────────────────────────────────────────────

abstract class P2PServiceInterface {
  Stream<P2PEvent> get events;
  List<DiscoveredPeer> get discoveredPeers;

  Future<void> init({required String deviceId, required String deviceName});
  void startAdvertising();
  void stopAdvertising();
  void startDiscovery();
  void stopDiscovery();
  Future<void> sendContent(String peerId, ContentItemEntity item);
  Future<void> sendModelUpdate(String peerId, Uint8List gradients);
  void dispose();
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

final p2pServiceProvider = Provider<P2PServiceInterface>((ref) {
  final P2PServiceInterface service;
  if (kIsWeb) {
    service = WebP2PService();
  } else {
    if (Platform.isAndroid) {
      service = AndroidP2PService();
    } else {
      service = LanP2PService();
    }
  }
  ref.onDispose(() {
    try {
      service.dispose();
    } catch (_) {
      // Web stub intentionally throws unsupported errors.
    }
  });
  return service;
});
