import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/entities.dart';
import 'p2p_service.dart';

class LanP2PService implements P2PServiceInterface {
  final _eventCtrl = StreamController<P2PEvent>.broadcast();
  final _peers = <String, DiscoveredPeer>{};
  final Map<String, Map<int, Uint8List>> _incomingChunks = {};

  ServerSocket? _server;
  RawDatagramSocket? _udpSocket;
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;

  String _myId = '';
  String _myName = '';
  bool _advertising = false;
  bool _discovering = false;

  @override
  Stream<P2PEvent> get events => _eventCtrl.stream;

  @override
  List<DiscoveredPeer> get discoveredPeers => _peers.values.toList();

  @override
  Future<void> init({required String deviceId, required String deviceName}) async {
    _myId = deviceId;
    _myName = deviceName;
    await _startTcpServer();
  }

  Future<void> _startTcpServer() async {
    try {
      _server = await ServerSocket.bind(
          InternetAddress.anyIPv4, P2PProtocol.servicePort,
          shared: true);
      _server!.listen(_handleIncomingConnection);
      debugPrint('[P2P Desktop] TCP server listening on port ${P2PProtocol.servicePort}');
    } catch (e) {
      _emit(P2PEvent(
          type: P2PEventType.error,
          errorMessage: 'Cannot bind TCP server: $e'));
    }
  }

  @override
  void startAdvertising() {
    if (_advertising) return;
    _advertising = true;
    _broadcastTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _broadcastPresence(),
    );
    _broadcastPresence();
    debugPrint('[P2P Desktop] Advertising started');
  }

  @override
  void stopAdvertising() {
    _advertising = false;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
  }

  Future<void> _broadcastPresence() async {
    try {
      final socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      final payload = jsonEncode({
        'tag': P2PProtocol.serviceTag,
        'id': _myId,
        'name': _myName,
        'port': P2PProtocol.servicePort,
      });
      socket.send(
        utf8.encode(payload),
        InternetAddress(P2PProtocol.broadcastAddress),
        P2PProtocol.discoveryPort,
      );
      socket.close();
    } catch (_) {}
  }

  @override
  void startDiscovery() {
    if (_discovering) return;
    _discovering = true;
    _bindUdpDiscovery();
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _evictStalePeers(),
    );
    debugPrint('[P2P Desktop] Discovery started');
  }

  @override
  void stopDiscovery() {
    _discovering = false;
    _udpSocket?.close();
    _udpSocket = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  Future<void> _bindUdpDiscovery() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4, P2PProtocol.discoveryPort,
          reuseAddress: true, reusePort: !Platform.isWindows);
      _udpSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = _udpSocket!.receive();
          if (dg == null) return;
          _handleDiscoveryPacket(dg);
        }
      });
    } catch (e) {
      debugPrint('[P2P Desktop] UDP discovery bind error: $e');
    }
  }

  void _handleDiscoveryPacket(Datagram dg) {
    try {
      final text = utf8.decode(dg.data);
      final map = jsonDecode(text) as Map<String, dynamic>;
      if (map['tag'] != P2PProtocol.serviceTag) return;
      final id = map['id'] as String;
      if (id == _myId) return;

      final isNew = !_peers.containsKey(id);
      _peers[id] = DiscoveredPeer(
        id: id,
        name: map['name'] as String? ?? id,
        address: dg.address.address,
        port: map['port'] as int? ?? P2PProtocol.servicePort,
        seenAt: DateTime.now(),
      );

      if (isNew) {
        _emit(P2PEvent(
          type: P2PEventType.peerDiscovered,
          peerId: id,
          peerName: _peers[id]!.name,
        ));
      }
    } catch (_) {}
  }

  void _evictStalePeers() {
    final cutoff =
        DateTime.now().subtract(const Duration(seconds: 15));
    final stale = _peers.entries
        .where((e) => e.value.seenAt.isBefore(cutoff))
        .map((e) => e.key)
        .toList();
    for (final id in stale) {
      _peers.remove(id);
      _emit(
          P2PEvent(type: P2PEventType.peerLost, peerId: id));
    }
  }

  @override
  Future<void> sendContent(String peerId, ContentItemEntity item) async {
    final peer = _peers[peerId];
    if (peer == null) {
      _emit(P2PEvent(
          type: P2PEventType.transferFailed,
          peerId: peerId,
          contentId: item.id,
          errorMessage: 'Peer not found'));
      return;
    }

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

      final socket =
          await Socket.connect(peer.address, peer.port);
      try {
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
          socket.add(chunk.toBytes());
          _emit(P2PEvent(
            type: P2PEventType.transferProgress,
            peerId: peerId,
            contentId: item.id,
            progress: (i + 1) / totalChunks,
          ));
          await socket.flush();
        }
      } finally {
        await socket.close();
      }

      _emit(P2PEvent(
          type: P2PEventType.transferComplete,
          peerId: peerId,
          contentId: item.id));
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
    final peer = _peers[peerId];
    if (peer == null) return;
    try {
      final socket =
          await Socket.connect(peer.address, peer.port);
      final header = jsonEncode({
        'tag': 'MODEL_UPDATE',
        'size': gradients.length,
      });
      final headerBytes = utf8.encode(header);
      final bb = ByteData(4 + headerBytes.length + gradients.length);
      bb.setUint32(0, headerBytes.length, Endian.big);
      for (int i = 0; i < headerBytes.length; i++) {
        bb.setUint8(4 + i, headerBytes[i]);
      }
      for (int i = 0; i < gradients.length; i++) {
        bb.setUint8(4 + headerBytes.length + i, gradients[i]);
      }
      socket.add(bb.buffer.asUint8List());
      await socket.flush();
      await socket.close();
    } catch (_) {}
  }

  void _handleIncomingConnection(Socket socket) {
    final buf = <int>[];
    socket.listen(
      (data) => buf.addAll(data),
      onDone: () => _processIncomingBuffer(
          Uint8List.fromList(buf), socket.remoteAddress.address),
      onError: (_) => socket.destroy(),
    );
  }

  void _processIncomingBuffer(Uint8List data, String fromAddress) {
    try {
      if (data.length < 4) return;
      final headerLen =
          ByteData.sublistView(data, 0, 4).getUint32(0, Endian.big);
      final headerJson = utf8.decode(data.sublist(4, 4 + headerLen));
      final header = jsonDecode(headerJson) as Map<String, dynamic>;

      if (header['tag'] == 'MODEL_UPDATE') {
        return;
      }

      final packet = ChunkPacket.fromBytes(data);
      _incomingChunks
          .putIfAbsent(packet.contentId, () => {})[packet.chunkIndex] =
          packet.payload;

      if (_incomingChunks[packet.contentId]!.length ==
          packet.totalChunks) {
        _reassemble(packet, fromAddress);
      }
    } catch (e) {
      debugPrint('[P2P Desktop] Error processing incoming buffer: $e');
    }
  }

  void _reassemble(ChunkPacket lastPacket, String fromAddress) {
    final maps = _incomingChunks.remove(lastPacket.contentId)!;
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
      fileBytes: bytes, // Pass bytes to save it
    ));
  }

  void _emit(P2PEvent event) {
    if (!_eventCtrl.isClosed) _eventCtrl.add(event);
  }

  @override
  void dispose() {
    stopAdvertising();
    stopDiscovery();
    _server?.close();
    _eventCtrl.close();
  }
}
