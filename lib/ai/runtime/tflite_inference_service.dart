import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart' if (dart.library.html) '../stubs/tflite_stub.dart' as tfl;

class TfliteModelNotFound implements Exception {
  final String modelAssetPath;
  const TfliteModelNotFound(this.modelAssetPath);

  @override
  String toString() => 'TfliteModelNotFound(modelAssetPath: $modelAssetPath)';
}

/// Minimal TFLite loader that works with asset paths on desktop.
class TfliteInferenceService {
  final String assetModelPath;
  tfl.Interpreter? _interpreter;

  TfliteInferenceService({required this.assetModelPath});

  Future<void> load({tfl.InterpreterOptions? options}) async {
    if (_interpreter != null) return;
    final bytes = await rootBundle.load(assetModelPath);
    final tmpDir = Directory.systemTemp;
    final file = File('${tmpDir.path}/${assetModelPath.split('/').last}');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    if (!file.existsSync()) throw TfliteModelNotFound(assetModelPath);
    _interpreter = tfl.Interpreter.fromFile(file, options: options);
  }

  tfl.Interpreter get interpreter {
    final i = _interpreter;
    if (i == null) throw StateError('TFLite interpreter not loaded');
    return i;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
