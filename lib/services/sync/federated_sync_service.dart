import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connectivity/connectivity_service.dart';
// connectivityServiceProvider is also defined in data_providers.dart via
// a re-export — use package import to be path-independent.
import 'package:learngrid/data/providers/data_providers.dart';

// ── Sync Status ───────────────────────────────────────────────────────────────

enum FLSyncStatus { idle, running, success, failed, disabled }

class FLSyncState {
  final FLSyncStatus status;
  final DateTime? lastSyncAt;
  final int? gradientBytesTransmitted;
  final String? errorMessage;

  const FLSyncState({
    this.status = FLSyncStatus.idle,
    this.lastSyncAt,
    this.gradientBytesTransmitted,
    this.errorMessage,
  });

  FLSyncState copyWith({
    FLSyncStatus? status,
    DateTime? lastSyncAt,
    int? gradientBytesTransmitted,
    String? errorMessage,
  }) =>
      FLSyncState(
        status: status ?? this.status,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        gradientBytesTransmitted:
            gradientBytesTransmitted ?? this.gradientBytesTransmitted,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Federated Sync Service ────────────────────────────────────────────────────

class FederatedSyncService {
  static const _lastSyncKey = 'fl_last_sync_ms';
  static const _syncIntervalMinutes = 60;

  final ConnectivityService _connectivity;
  final _log = Logger();

  FederatedSyncService({required ConnectivityService connectivity})
      : _connectivity = connectivity;

  final _stateCtrl =
      StreamController<FLSyncState>.broadcast();

  FLSyncState _state = const FLSyncState();

  Stream<FLSyncState> get stateStream => _stateCtrl.stream;
  FLSyncState get currentState => _state;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Tries to run the federated learning sync if conditions allow.
  /// Conditions:
  ///   1. Internet is available.
  ///   2. Last sync was > [_syncIntervalMinutes] minutes ago.
  Future<void> trySyncIfDue() async {
    if (_state.status == FLSyncStatus.running) return;

    final hasNet = await _connectivity.hasInternet();
    if (!hasNet) {
      _log.d('[FL] No internet — skipping sync');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastSyncMs = prefs.getInt(_lastSyncKey) ?? 0;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
    final minutesSinceLast =
        DateTime.now().difference(lastSync).inMinutes;

    if (minutesSinceLast < _syncIntervalMinutes) {
      _log.d(
          '[FL] Sync not due yet ($minutesSinceLast / $_syncIntervalMinutes min)');
      return;
    }

    await _runSync();
  }

  /// Force a sync regardless of the interval.
  Future<void> forceSync() => _runSync();

  void dispose() => _stateCtrl.close();

  // ── Private sync logic ────────────────────────────────────────────────────

  Future<void> _runSync() async {
    _emit(_state.copyWith(status: FLSyncStatus.running));
    _log.i('[FL] Starting federated learning sync…');

    try {
      final scriptPath = await _resolveScriptPath();
      if (scriptPath == null) {
        _emit(_state.copyWith(
          status: FLSyncStatus.failed,
          errorMessage: 'fl_client.py not found',
        ));
        return;
      }

      final dbPath = await _resolveDatabasePath();

      // Run the Python FL client as a subprocess.
      final result = await Process.run(
        _pythonExecutable(),
        [scriptPath, dbPath],
        workingDirectory: Directory.current.path,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final bytesLine = RegExp(r'Gradient bytes transmitted: (\d+)')
            .firstMatch(output);
        final bytes =
            int.tryParse(bytesLine?.group(1) ?? '') ?? 0;

        final now = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            _lastSyncKey, now.millisecondsSinceEpoch);

        _emit(_state.copyWith(
          status: FLSyncStatus.success,
          lastSyncAt: now,
          gradientBytesTransmitted: bytes,
        ));
        _log.i('[FL] Sync succeeded. Gradient bytes: $bytes');
      } else {
        final stderr = result.stderr.toString();
        _emit(_state.copyWith(
          status: FLSyncStatus.failed,
          errorMessage: stderr.isNotEmpty ? stderr : 'Exit ${result.exitCode}',
        ));
        _log.e('[FL] Sync failed: $stderr');
      }
    } catch (e) {
      _emit(_state.copyWith(
        status: FLSyncStatus.failed,
        errorMessage: '$e',
      ));
      _log.e('[FL] Sync exception: $e');
    }
  }

  Future<String?> _resolveScriptPath() async {
    // Look for fl_client.py next to the executable, then fall back to CWD.
    final candidates = [
      '${Directory.current.path}/scripts/fl_client.py',
      '${Platform.resolvedExecutable.split(Platform.pathSeparator).take(Platform.resolvedExecutable.split(Platform.pathSeparator).length - 1).join(Platform.pathSeparator)}/scripts/fl_client.py',
    ];
    for (final p in candidates) {
      if (File(p).existsSync()) return p;
    }
    // Also check relative to app support dir.
    try {
      final appDir = await getApplicationSupportDirectory();
      final p = '${appDir.path}/scripts/fl_client.py';
      if (File(p).existsSync()) return p;
    } catch (_) {}
    return null;
  }

  Future<String> _resolveDatabasePath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return '${appDir.path}/learngrid.db';
    } catch (_) {
      return 'learngrid.db';
    }
  }

  String _pythonExecutable() {
    if (Platform.isWindows) return 'python';
    return 'python3';
  }

  void _emit(FLSyncState state) {
    _state = state;
    if (!_stateCtrl.isClosed) _stateCtrl.add(state);
  }
}

// ── Riverpod ──────────────────────────────────────────────────────────────────

final federatedSyncProvider =
    Provider<FederatedSyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final service =
      FederatedSyncService(connectivity: connectivity);
  ref.onDispose(service.dispose);
  return service;
});

final flSyncStateProvider =
    StreamProvider<FLSyncState>((ref) {
  return ref.watch(federatedSyncProvider).stateStream;
});
