import 'dart:isolate';
import 'package:learngrid/ai/speech/whisper_service.dart';

/// Isolate entry point for running Whisper transcription in the background.
/// The isolate receives a SendPort as its initial message and uses that
/// to reply back to the spawner.
void main(List<String> args, SendPort sendPort) {
  final receivePort = ReceivePort();
  // Tell the spawner our ReceivePort so it can send commands.
  sendPort.send(receivePort.sendPort);

  receivePort.listen((dynamic message) async {
    try {
      final command = message[0] as String;

      if (command == 'transcribe') {
        final audioFilePath = message[1] as String;
        final result = await _transcribeAudio(audioFilePath);
        sendPort.send(result);
      } else {
        sendPort.send('ERROR: Unknown command: $command');
      }
    } catch (e, stackTrace) {
      sendPort.send('ERROR: $e\n$stackTrace');
    }
  });
}

Future<List<Map<String, dynamic>>> _transcribeAudio(String audioFilePath) async {
  final whisperService = WhisperService();
  await whisperService.initialize();
  final chunks = await whisperService.transcribeAudio(audioFilePath);
  return chunks
      .map((c) => <String, dynamic>{'text': c.text, 'start': (c.startTime * 1000).round(), 'end': (c.endTime * 1000).round()})
      .toList();
}
