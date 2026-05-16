import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_processing_queue.dart';

// Riverpod provider for the singleton image processing queue
final imageQueueProvider = Provider<ImageProcessingQueue>((ref) {
  final queue = ImageProcessingQueue();
  ref.onDispose(queue.dispose);
  return queue;
});
