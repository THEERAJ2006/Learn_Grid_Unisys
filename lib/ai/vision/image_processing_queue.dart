import 'dart:async';
import 'dart:collection';

// Simplified, safe, single-threaded queue to serialize image processing tasks
typedef ImageTask<T> = Future<T> Function(String imagePath);

class _QueueEntry<T> {
  final String imagePath;
  final ImageTask<T> task;
  final Completer<T> completer;
  _QueueEntry(this.imagePath, this.task, this.completer);
}

class ImageProcessingQueue {
  ImageProcessingQueue._internal();
  static final ImageProcessingQueue _instance = ImageProcessingQueue._internal();
  factory ImageProcessingQueue() => _instance;

  final Queue<_QueueEntry> _queue = Queue<_QueueEntry>();
  bool _isProcessing = false;
  final _processingController = StreamController<bool>.broadcast();
  Stream<bool> get isProcessingStream => _processingController.stream;

  Future<T> enqueue<T>(String imagePath, ImageTask<T> task) {
    final completer = Completer<T>();
    _queue.add(_QueueEntry<T>(imagePath, task, completer));
    _processNext<T>();
    return completer.future;
  }

  void _processNext<T>() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;
    _processingController.add(true);
    final entry = _queue.removeFirst();
    try {
      final result = await entry.task(entry.imagePath);
      entry.completer.complete(result);
    } catch (e) {
      entry.completer.completeError(e);
    } finally {
      _isProcessing = false;
      _processingController.add(false);
      _processNext<T>();
    }
  }

  void dispose() {
    _processingController.close();
  }
}

