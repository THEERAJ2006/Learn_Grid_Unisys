import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'ble_service.dart';

// ── BLE Service Provider ──────────────────────────────────────────────────────

final bleServiceProvider = Provider<BLEService>((ref) {
  final BLEService service;
  
  if (kIsWeb) {
    service = WebBLEService();
  } else if (Platform.isAndroid || Platform.isIOS) {
    service = StubBLEService();
  } else {
    service = StubBLEService();
  }
  
  ref.onDispose(service.dispose);
  return service;
});

/// Stream of BLE events
final bleEventsProvider = StreamProvider<BLEEvent>((ref) {
  final service = ref.watch(bleServiceProvider);
  return service.events;
});

/// List of discovered BLE devices
final bleDiscoveredDevicesProvider = StateProvider<int>((ref) {
  final service = ref.watch(bleServiceProvider);
  return service.discoveredDevices.length;
});

/// Scanning state
final bleScanningProvider = StateProvider<bool>((ref) => false);

/// Connected devices count
final bleConnectedDevicesProvider = StateProvider<int>((ref) => 0);
