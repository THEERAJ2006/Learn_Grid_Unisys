import 'dart:async';
import 'dart:isolate';

/// Runs AI inference in background isolates to prevent UI blocking.
class AIInferenceIsolate {
  static Future<List<double>> embedInIsolate(String text) async {
    final receivePort = ReceivePort();
    final completer = Completer<List<double>>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/embedding_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    // The isolate sends back its own ReceivePort's sendPort as the first message.
    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['embed', text]);
      } else if (message is List<double>) {
        completer.complete(message);
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<List<Map<String, dynamic>>> transcribeInIsolate(
      String audioFilePath) async {
    final receivePort = ReceivePort();
    final completer = Completer<List<Map<String, dynamic>>>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/whisper_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['transcribe', audioFilePath]);
      } else if (message is List) {
        completer
            .complete(message.cast<Map<String, dynamic>>());
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<String> classifyImageInIsolate(String imagePath) async {
    final receivePort = ReceivePort();
    final completer = Completer<String>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/image_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['classify_image', imagePath]);
      } else if (message is String && !message.startsWith('ERROR:')) {
        completer.complete(message);
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<List<Map<String, dynamic>>> detectRegionsInIsolate(
      String imagePath) async {
    final receivePort = ReceivePort();
    final completer = Completer<List<Map<String, dynamic>>>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/image_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['detect_regions', imagePath]);
      } else if (message is List) {
        completer.complete(message.cast<Map<String, dynamic>>());
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<String> generateCaptionInIsolate(String imagePath) async {
    final receivePort = ReceivePort();
    final completer = Completer<String>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/image_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['generate_caption', imagePath]);
      } else if (message is String && !message.startsWith('ERROR:')) {
        completer.complete(message);
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<String> predictEngagementInIsolate(
      List<double> features) async {
    final receivePort = ReceivePort();
    final completer = Completer<String>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/engagement_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['predict_engagement', features]);
      } else if (message is String && !message.startsWith('ERROR:')) {
        completer.complete(message);
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }

  static Future<List<double>> predictRecommendationInIsolate(
      List<double> features) async {
    final receivePort = ReceivePort();
    final completer = Completer<List<double>>();

    await Isolate.spawnUri(
      Uri.parse('package:learngrid/ai/isolates/recommendation_isolate.dart'),
      [],
      receivePort.sendPort,
    );

    SendPort? toIsolate;
    receivePort.listen((dynamic message) {
      if (toIsolate == null && message is SendPort) {
        toIsolate = message;
        toIsolate!.send(['predict_recommendation', features]);
      } else if (message is List<double>) {
        completer.complete(message);
        receivePort.close();
      } else if (message is String && message.startsWith('ERROR:')) {
        completer.completeError(Exception(message.substring(6)));
        receivePort.close();
      }
    });

    return completer.future;
  }
}
