class ModelNotReadyException implements Exception {
  final String message;
  ModelNotReadyException([this.message = 'Web: AI runs via cloud only']);
  @override
  String toString() => 'ModelNotReadyException: $message';
}

class Interpreter {
  static Future<Interpreter> fromAsset(String assetName, {dynamic options}) async {
    throw ModelNotReadyException();
  }
  void run(Object input, Object output) {
    throw ModelNotReadyException();
  }
  void runForMultipleInputs(List<Object> inputs, Map<int, Object> outputs) {
    throw ModelNotReadyException();
  }
  void close() {}
}

class InterpreterOptions {
  void addDelegate(dynamic delegate) {}
}
