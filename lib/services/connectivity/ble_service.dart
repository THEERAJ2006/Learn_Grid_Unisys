import 'dart:async';
import 'package:flutter/foundation.dart';

// ── BLE Protocol (Simplified - Uses BLE-like discovery over Bluetooth/WiFi) ───

class BLEProtocol {
  static const serviceUUID = '12345678-1234-5678-1234-56789abcdef0';
  static const peerInfoCharUUID = '12345678-1234-5678-1234-56789abcdef1';
  static const dataCharUUID = '12345678-1234-5678-1234-56789abcdef2';
  static const advertisementNamePrefix = 'LearnGrid';
}

// ── BLE Events ─────────────────────────────────────────────────────────────────

enum BLEEventType {
  scanStarted,
  scanStopped,
  deviceDiscovered,
  deviceLost,
  connected,
  disconnected,
  dataReceived,
  characteristicRead,
  characteristicWrite,
  error,
}

class BLEEvent {
  final BLEEventType type;
  final String? deviceId;
  final String? deviceName;
  final int? rssi; // Signal strength
  final Uint8List? data;
  final String? errorMessage;

  const BLEEvent({
    required this.type,
    this.deviceId,
    this.deviceName,
    this.rssi,
    this.data,
    this.errorMessage,
  });
}

// Stub for BLE device (simplified representation)
class BLEDevice {
  final String id;
  final String name;

  BLEDevice({required this.id, required this.name});
}

// ── BLE Service Interface ──────────────────────────────────────────────────────

abstract class BLEService {
  Stream<BLEEvent> get events;
  List<BLEDevice> get discoveredDevices;
  
  Future<void> init();
  Future<void> startScanning({Duration timeout = const Duration(seconds: 30)});
  Future<void> stopScanning();
  Future<void> startAdvertising({required String deviceName});
  Future<void> stopAdvertising();
  Future<void> connectToDevice(BLEDevice device);
  Future<void> disconnectDevice(BLEDevice device);
  Future<void> sendData(BLEDevice device, Uint8List data);
  void dispose();
}

// ── Simplified BLE Implementation ──────────────────────────────────────────────

class StubBLEService implements BLEService {
  final _eventCtrl = StreamController<BLEEvent>.broadcast();
  final _discoveredDevices = <String, BLEDevice>{};
  Timer? _scanTimer;
  bool _isScanning = false;

  @override
  Stream<BLEEvent> get events => _eventCtrl.stream;

  @override
  List<BLEDevice> get discoveredDevices => _discoveredDevices.values.toList();

  @override
  Future<void> init() async {
    debugPrint('[BLE] Initialized (stub implementation)');
  }

  @override
  Future<void> startScanning({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isScanning) return;

    try {
      _isScanning = true;
      _emit(BLEEvent(type: BLEEventType.scanStarted));

      // Simulate device discovery
      _scanTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        // Simulate finding devices
        final deviceId = 'BLE_Device_${_discoveredDevices.length}';
        final device = BLEDevice(
          id: deviceId,
          name: '${BLEProtocol.advertisementNamePrefix}_${_discoveredDevices.length}',
        );
        if (!_discoveredDevices.containsKey(deviceId)) {
          _discoveredDevices[deviceId] = device;
          _emit(BLEEvent(
            type: BLEEventType.deviceDiscovered,
            deviceId: deviceId,
            deviceName: device.name,
            rssi: -65 - (_discoveredDevices.length * 5),
          ));
        }
      });

      // Stop scan after timeout
      Future.delayed(timeout, () {
        if (_isScanning) stopScanning();
      });
    } catch (e) {
      _emit(BLEEvent(
        type: BLEEventType.error,
        errorMessage: 'Scan failed: $e',
      ));
      _isScanning = false;
    }
  }

  @override
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      _scanTimer?.cancel();
      _isScanning = false;
      _emit(BLEEvent(type: BLEEventType.scanStopped));
    } catch (e) {
      _emit(BLEEvent(
        type: BLEEventType.error,
        errorMessage: 'Stop scan failed: $e',
      ));
    }
  }

  @override
  Future<void> startAdvertising({required String deviceName}) async {
    try {
      debugPrint('[BLE] Advertising as: LearnGrid-$deviceName');
    } catch (e) {
      _emit(BLEEvent(
        type: BLEEventType.error,
        errorMessage: 'Advertise failed: $e',
      ));
    }
  }

  @override
  Future<void> stopAdvertising() async {
    debugPrint('[BLE] Stopped advertising');
  }

  @override
  Future<void> connectToDevice(BLEDevice device) async {
    try {
      _emit(BLEEvent(
        type: BLEEventType.connected,
        deviceId: device.id,
        deviceName: device.name,
      ));
    } catch (e) {
      _emit(BLEEvent(
        type: BLEEventType.error,
        errorMessage: 'Connection failed: $e',
      ));
    }
  }

  @override
  Future<void> disconnectDevice(BLEDevice device) async {
    try {
      _emit(BLEEvent(
        type: BLEEventType.disconnected,
        deviceId: device.id,
      ));
    } catch (e) {
      _emit(BLEEvent(
        type: BLEEventType.error,
        errorMessage: 'Disconnect failed: $e',
      ));
    }
  }

  @override
  Future<void> sendData(BLEDevice device, Uint8List data) async {
    try {
      _emit(BLEEvent(
        type: BLEEventType.dataReceived,
        deviceId: device.id,
        data: data,
      ));
    } catch (e) {
      _emit(BLEEvent(
        type: BLEEventType.error,
        errorMessage: 'Send data failed: $e',
      ));
    }
  }

  void _emit(BLEEvent event) {
    if (!_eventCtrl.isClosed) _eventCtrl.add(event);
  }

  @override
  void dispose() {
    stopScanning();
    _eventCtrl.close();
  }
}

// ── Web stub (BLE not available)

class WebBLEService implements BLEService {
  @override
  Stream<BLEEvent> get events => const Stream.empty();

  @override
  List<BLEDevice> get discoveredDevices => [];

  @override
  Future<void> init() async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> startScanning({Duration timeout = const Duration(seconds: 30)}) async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> stopScanning() async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> startAdvertising({required String deviceName}) async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> stopAdvertising() async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> connectToDevice(BLEDevice device) async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> disconnectDevice(BLEDevice device) async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  Future<void> sendData(BLEDevice device, Uint8List data) async {
    throw UnsupportedError('BLE not available on web');
  }

  @override
  void dispose() {}
}

