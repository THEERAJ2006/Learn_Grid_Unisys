import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // for kDebugMode, debugPrint
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart' as ort;

import 'onnx_inference_service.dart';

/// ONNX runtime adapter for `flutter_onnxruntime`.
///
/// This copies the asset to a readable file path before opening.
class FlutterOnnxruntimeInferenceService implements OnnxInferenceService {
  final String assetModelPath;

  bool _loaded = false;
  String? _resolvedModelPath;
  ort.OrtSession? _session;
  final ort.OnnxRuntime _runtime = ort.OnnxRuntime();

  FlutterOnnxruntimeInferenceService({required this.assetModelPath});

  @override
  Future<void> load() async {
    if (_loaded) return;

    final bytes = await rootBundle.load(assetModelPath);
    final tmpDir = Directory.systemTemp;
    final file = File('${tmpDir.path}/${assetModelPath.split('/').last}');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    _resolvedModelPath = file.path;

    final modelPath = _resolvedModelPath;
    if (modelPath == null || !File(modelPath).existsSync()) {
      throw OnnxModelNotFound(assetModelPath);
    }

    _session = await _runtime.createSession(modelPath);
    _loaded = true;
  }

  @override
  Future<Map<String, Object?>> run({
    required Map<String, Object?> inputs,
    required List<String> outputNames,
  }) async {
    if (!_loaded) await load();
    final session = _session;
    if (session == null) throw StateError('ONNX session not available');

    // `flutter_onnxruntime` expects OrtValue inputs and returns OrtValue outputs.
    // We keep a minimal conversion layer so feature code stays runtime-agnostic.
    final createdInputs = <String, ort.OrtValue>{};
    try {
      for (final entry in inputs.entries) {
        final name = entry.key;
        final v = entry.value;
        if (v is Float32List) {
          createdInputs[name] = await ort.OrtValue.fromList(v, [1, v.length]);
        } else if (v is Int64List) {
          createdInputs[name] = await ort.OrtValue.fromList(v, [1, v.length]);
        } else if (v is Int32List) {
          createdInputs[name] = await ort.OrtValue.fromList(v, [1, v.length]);
        } else if (v is List<int>) {
          // Default to int64 for token ids.
          createdInputs[name] = await ort.OrtValue.fromList(Int64List.fromList(v), [1, v.length]);
        } else {
          throw OnnxInvalidInput('Unsupported input type for $name: ${v.runtimeType}');
        }
      }

      final outputs = await session.run(createdInputs);
      // Diagnostic: log real output keys on first inference (debug builds only).
      if (kDebugMode) {
        debugPrint('[OnnxRuntime] Output keys from model: ${outputs.keys.toList()}');
      }
      final out = <String, Object?>{};
      for (final name in outputNames) {
        final ov = outputs[name];
        if (ov == null) continue;
        // Prefer a float32 flattened vector when possible.
        if (ov.dataType == ort.OrtDataType.float32) {
          final data = await ov.asFlattenedList();
          out[name] = Float32List.fromList(data.map((e) => (e as num).toDouble()).toList(growable: false));
        } else {
          out[name] = await ov.asFlattenedList();
        }
      }
      return out;
    } finally {
      // Release native resources.
      for (final v in createdInputs.values) {
        await v.dispose();
      }
    }
  }

  @override
  void dispose() {
    _session?.close();
    _session = null;
    _loaded = false;
  }
}
