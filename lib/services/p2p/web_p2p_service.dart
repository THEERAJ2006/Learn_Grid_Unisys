import 'dart:async';
import 'dart:typed_data';

import '../../data/models/entities.dart';
import 'p2p_service.dart';

class WebP2PService implements P2PServiceInterface {
  @override
  Stream<P2PEvent> get events => const Stream.empty();

  @override
  List<DiscoveredPeer> get discoveredPeers => [];

  @override
  Future<void> init({required String deviceId, required String deviceName}) async {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  void startAdvertising() {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  void stopAdvertising() {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  void startDiscovery() {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  void stopDiscovery() {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  Future<void> sendContent(String peerId, ContentItemEntity item) async {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  Future<void> sendModelUpdate(String peerId, Uint8List gradients) async {
    throw UnsupportedError('P2P not available on web');
  }

  @override
  void dispose() {
    throw UnsupportedError('P2P not available on web');
  }
}
