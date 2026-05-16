import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/entities.dart';
import 'p2p_service.dart';

class AndroidP2PService implements P2PServiceInterface {
  static const String serviceId = "com.learngrid.p2p";
  
  final _eventCtrl = StreamController<P2PEvent>.broadcast();
  final _peers = <String, DiscoveredPeer>{};
  
  // connectionId -> { contentId -> { chunkIndex -> bytes } }
  final Map<String, Map<String, Map<int, Uint8List>>> _incomingChunks = {};

  String _myName = '';
  bool _advertising = false;
  bool _discovering = false;

  @override
  Stream<P2PEvent> get events => _eventCtrl.stream;

  @override
  List<DiscoveredPeer> get discoveredPeers => _peers.values.toList();

  @override
  Future<void> init({required String deviceId, required String deviceName}) async {
    _myName = deviceName;
  }

  @override
  void startAdvertising() async {
    if (_advertising) return;
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) return;
      
      _advertising = await Nearby().startAdvertising(
        _myName,
        Strategy.P2P_STAR,
        onConnectionInitiated: (id, info) async {
          _emit(P2PEvent(
            type: P2PEventType.connectionRequested,
            peerId: id,
            peerName: info.endpointName,
          ));
          await Nearby().acceptConnection(
            id,
            onPayLoadRecieved: _onPayloadReceived,
            onPayloadTransferUpdate: _onPayloadTransferUpdate,
          );
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            _emit(P2PEvent(type: P2PEventType.connected, peerId: id));
          } else {
            _emit(P2PEvent(type: P2PEventType.disconnected, peerId: id));
          }
        },
        onDisconnected: (id) {
          _emit(P2PEvent(type: P2PEventType.disconnected, peerId: id));
        },
        serviceId: serviceId,
      );
    } catch (e) {
      debugPrint('[P2P Android] Advertising error: $e');
    }
  }

  @override
  void stopAdvertising() async {
    if (!_advertising) return;
    await Nearby().stopAdvertising();
    _advertising = false;
  }

  @override
  void startDiscovery() async {
    if (_discovering) return;
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) return;

      _discovering = await Nearby().startDiscovery(
        _myName,
        Strategy.P2P_STAR,
        onEndpointFound: (id, name, serviceId) {
          _peers[id] = DiscoveredPeer(
            id: id,
            name: name,
            address: '',
            port: 0,
            seenAt: DateTime.now(),
          );
          _emit(P2PEvent(
            type: P2PEventType.peerDiscovered,
            peerId: id,
            peerName: name,
          ));
        },
        onEndpointLost: (id) {
          _peers.remove(id);
          _emit(P2PEvent(type: P2PEventType.peerLost, peerId: id));
        },
        serviceId: serviceId,
      );
    } catch (e) {
      debugPrint('[P2P Android] Discovery error: $e');
    }
  }

  @override
  void stopDiscovery() async {
    if (!_discovering) return;
    await Nearby().stopDiscovery();
    _discovering = false;
  }

  @override
  Future<void> sendContent(String peerId, ContentItemEntity item) async {
    try {
      final file = File(item.filePath);
      if (!file.existsSync()) {
        _emit(P2PEvent(
            type: P2PEventType.transferFailed,
            peerId: peerId,
            contentId: item.id,
            errorMessage: 'File not found: ${item.filePath}'));
        return;
      }
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();

      final totalChunks = (bytes.length / P2PProtocol.chunkSize).ceil().clamp(1, 99999);
      _emit(P2PEvent(
          type: P2PEventType.transferStarted,
          peerId: peerId,
          contentId: item.id));

      // Connect if not connected
      await Nearby().requestConnection(
        _myName,
        peerId,
        onConnectionInitiated: (id, info) async {
          await Nearby().acceptConnection(
            id,
            onPayLoadRecieved: _onPayloadReceived,
            onPayloadTransferUpdate: _onPayloadTransferUpdate,
          );
        },
        onConnectionResult: (id, status) async {
          if (status == Status.CONNECTED) {
            _emit(P2PEvent(type: P2PEventType.connected, peerId: id));
            // Send chunks
            for (int i = 0; i < totalChunks; i++) {
              final start = i * P2PProtocol.chunkSize;
              final end = (start + P2PProtocol.chunkSize).clamp(0, bytes.length);
              final chunk = ChunkPacket(
                contentId: item.id,
                chunkIndex: i,
                totalChunks: totalChunks,
                contentType: item.type,
                contentTitle: item.title,
                sha256: hash,
                payload: bytes.sublist(start, end),
              );
              await Nearby().sendBytesPayload(id, chunk.toBytes());
              _emit(P2PEvent(
                type: P2PEventType.transferProgress,
                peerId: peerId,
                contentId: item.id,
                progress: (i + 1) / totalChunks,
              ));
              // Slight delay to avoid buffer overflows on older devices
              await Future.delayed(const Duration(milliseconds: 10));
            }
            _emit(P2PEvent(
                type: P2PEventType.transferComplete,
                peerId: peerId,
                contentId: item.id));
          }
        },
        onDisconnected: (id) {
          _emit(P2PEvent(type: P2PEventType.disconnected, peerId: id));
        },
      );
    } catch (e) {
      _emit(P2PEvent(
        type: P2PEventType.transferFailed,
        peerId: peerId,
        contentId: item.id,
        errorMessage: '$e',
      ));
    }
  }

  @override
  Future<void> sendModelUpdate(String peerId, Uint8List gradients) async {
    // Send directly if connected
    try {
      final chunk = ChunkPacket(
        contentId: 'MODEL_UPDATE',
        chunkIndex: 0,
        totalChunks: 1,
        contentType: 'model/gradients',
        contentTitle: 'Federated Gradients',
        sha256: '',
        payload: gradients,
      );
      await Nearby().sendBytesPayload(peerId, chunk.toBytes());
    } catch (_) {}
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      _processIncomingBuffer(endpointId, payload.bytes!);
    }
  }

  void _onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) {}

  void _processIncomingBuffer(String endpointId, Uint8List data) {
    try {
      if (data.length < 4) return;
      final packet = ChunkPacket.fromBytes(data);
      
      if (packet.contentId == 'MODEL_UPDATE') {
        return; // handle gradients
      }

      _incomingChunks.putIfAbsent(endpointId, () => {});
      _incomingChunks[endpointId]!.putIfAbsent(packet.contentId, () => {})[packet.chunkIndex] = packet.payload;

      if (_incomingChunks[endpointId]![packet.contentId]!.length == packet.totalChunks) {
        _reassemble(endpointId, packet);
      }
    } catch (e) {
      debugPrint('[P2P Android] Error processing buffer: $e');
    }
  }

  void _reassemble(String endpointId, ChunkPacket lastPacket) {
    final maps = _incomingChunks[endpointId]!.remove(lastPacket.contentId)!;
    final assembled = <int>[];
    for (int i = 0; i < lastPacket.totalChunks; i++) {
      assembled.addAll(maps[i] ?? []);
    }
    final bytes = Uint8List.fromList(assembled);

    final actualHash = sha256.convert(bytes).toString();
    if (actualHash != lastPacket.sha256) {
      _emit(P2PEvent(
        type: P2PEventType.transferFailed,
        contentId: lastPacket.contentId,
        errorMessage: 'SHA-256 mismatch — transfer corrupted',
      ));
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final received = ContentItemEntity(
      id: lastPacket.contentId,
      title: lastPacket.contentTitle,
      type: lastPacket.contentType,
      filePath: '',
      difficultyLevel: 1,
      language: 'en',
      fileSize: bytes.length,
      addedAt: now,
    );

    _emit(P2PEvent(
      type: P2PEventType.transferComplete,
      contentId: lastPacket.contentId,
      receivedContent: received,
      fileBytes: bytes,
    ));
  }

  void _emit(P2PEvent event) {
    if (!_eventCtrl.isClosed) _eventCtrl.add(event);
  }

  @override
  void dispose() {
    stopAdvertising();
    stopDiscovery();
    Nearby().stopAllEndpoints();
    _eventCtrl.close();
  }
}
