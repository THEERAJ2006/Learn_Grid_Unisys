// RUNTIME: using onnxruntime_flutter
// Swap: replace imports + session calls only — API unchanged.

import 'dart:typed_data';

/// Backend-agnostic ONNX inference wrapper.
///
/// No feature/screen code should import an ONNX package directly.
abstract class OnnxInferenceService {
  Future<void> load();

  /// Runs model inference.
  ///
  /// Inputs/outputs are intentionally typed as dynamic-ish containers so we can
  /// swap runtimes without cascading changes.
  Future<Map<String, Object?>> run({
    required Map<String, Object?> inputs,
    required List<String> outputNames,
  });

  void dispose();
}

class OnnxModelNotFound implements Exception {
  final String modelPath;
  const OnnxModelNotFound(this.modelPath);

  @override
  String toString() => 'OnnxModelNotFound(modelPath: $modelPath)';
}

class OnnxInvalidInput implements Exception {
  final String message;
  const OnnxInvalidInput(this.message);

  @override
  String toString() => 'OnnxInvalidInput($message)';
}

/// Convenience helper used by runtimes.
Uint8List asUint8List(Object? x, {required String name}) {
  if (x is Uint8List) return x;
  throw OnnxInvalidInput('Expected Uint8List for $name');
}
