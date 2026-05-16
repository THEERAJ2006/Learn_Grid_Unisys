import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'image_processing_queue.dart';
import 'package:path/path.dart' as p;
import 'package:tflite_flutter/tflite_flutter.dart' if (dart.library.html) '../stubs/tflite_stub.dart' as tfl;

/// Detected region in an image (for object detection)
class DetectedRegion {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final List<String> attributes;

  DetectedRegion({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.attributes = const [],
  });

  @override
  String toString() {
    return 'DetectedRegion(label: $label, confidence: ${confidence.toStringAsFixed(2)}, bbox: $boundingBox)';
  }
}

/// Rectangle representation
class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;

  Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  }) : width = right - left,
       height = bottom - top;

  @override
  String toString() {
    return 'Rect(x: ${left.toStringAsFixed(1)}, y: ${top.toStringAsFixed(1)}, w: ${width.toStringAsFixed(1)}, h: ${height.toStringAsFixed(1)})';
  }
}

/// Image processing service for classification, detection, and captioning
class ImageService {
  // Model paths
  // NOTE: Used when real model loads
  // ignore: unused_field
  static const String _classifierModelPath = 'assets/models/mobilenet_v2_classifier.tflite';

  // NOTE: Used when real model loads
  // ignore: unused_field
  static const String _detectorModelPath = 'assets/models/ssd_mobilenet_detection.tflite';

  // NOTE: Used when real model loads
  // ignore: unused_field
  static const String _captionModelPath = 'assets/models/blip_caption.onnx';
  
  // Model instances
  tfl.Interpreter? _classifierInterpreter;
  tfl.Interpreter? _detectorInterpreter;
  dynamic _captionSession; // Would be OnnxRuntime session
  bool _loaded = false;
  
  // Image processing queue (singleton; integrated with Riverpod provider)
  static final ImageProcessingQueue _imageQueue = ImageProcessingQueue();
  
  // Image classification categories (simplified)
  // NOTE: Used when real classifier output is decoded
  // ignore: unused_field
  static const Map<int, String> _imageCategories = {
    0: 'diagram',
    1: 'organ',
    2: 'flowchart',
    3: 'plain',
    4: 'labeled',
    5: 'chart',
    6: 'graph',
    7: 'table',
    8: 'map',
    9: 'illustration',
  };

  ImageService();

  /// Initialize image processing service
  Future<void> initialize() async {
    if (kIsWeb) throw UnsupportedError('Web: AI runs via cloud only');
    if (_loaded) return;
    try {
      // Load MobileNet classifier (would load in production)
      // _classifierInterpreter = await tfl.Interpreter.fromAsset(_classifierModelPath);
      
      // Load SSD MobileNet detector (would load in production)
      // _detectorInterpreter = await tfl.Interpreter.fromAsset(_detectorModelPath);
      
      // Load BLIP caption model (would load in production)
      // _captionSession = await OnnxRuntime.load(_captionModelPath);
      
      await Future.delayed(const Duration(milliseconds: 300));
      _loaded = true;
      // ignore: avoid_print
      print('ImageService initialized');
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing ImageService: $e');
      rethrow;
    }
  }

  /// Classify image type
  Future<String> classifyImageType(String imagePath) async {
    // ignore: avoid_print
    print('Classifying image: $imagePath');
    
    // In production: Load and preprocess image, run inference
    // final imageBytes = await _loadImageBytes(imagePath);
    // final input = _preprocessImageForClassification(imageBytes);
    // final output = await _runClassifierInference(input);
    // final categoryIndex = _interpretClassificationOutput(output);
    
    // Offload to image processing queue to ensure serial processing
    return _imageQueue.enqueue<String>(imagePath, (path) async {
      // For demonstration, simulate classification based on filename
      final fileName = p.basename(path).toLowerCase();
      return _simulateClassification(fileName);
    });
  }

  /// Detect regions in image
  Future<List<DetectedRegion>> detectRegions(String imagePath) async {
    // ignore: avoid_print
    print('Detecting regions in: $imagePath');
    
    // In production: Load and preprocess image, run detection
    // final imageBytes = await _loadImageBytes(imagePath);
    // final input = _preprocessImageForDetection(imageBytes);
    // final outputs = await _runDetectionInference(input);
    // final regions = _interpretDetectionOutput(outputs);
    
    // Offload to image processing queue as well
    return _imageQueue.enqueue<List<DetectedRegion>>(imagePath, (path) async {
      final imageType = await classifyImageType(path);
      return _simulateDetections(imageType);
    });
  }

  /// Generate caption for image
  Future<String> generateCaption(String imagePath) async {
    // ignore: avoid_print
    print('Generating caption for: $imagePath');
    
    // In production: Load and preprocess image, run caption model
    // final imageBytes = await _loadImageBytes(imagePath);
    // final input = _preprocessImageForCaptioning(imageBytes);
    // final output = await _runCaptionInference(input);
    // final caption = _interpretCaptionOutput(output);
    
    // Offload to image processing queue
    return _imageQueue.enqueue<String>(imagePath, (path) async {
      final imageType = await classifyImageType(path);
      return _generateSimulatedCaption(path, imageType);
    });
  }

  /// Extract OCR text from labeled images
  Future<String> extractOCRText(String imagePath) async {
    // ignore: avoid_print
    print('Extracting OCR text from: $imagePath');
    
    try {
      // Check if it's a labeled image
      final imageType = await classifyImageType(imagePath);
      if (imageType != 'labeled' && imageType != 'diagram' && imageType != 'chart') {
        return ''; // No OCR for non-labeled images
      }
      
      // In production: Use Google ML Kit for text recognition
      // final inputImage = InputImage.fromFilePath(imagePath);
      // final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      // final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      // final ocrText = recognizedText.text;
      // textRecognizer.close();
      
      // Offload to queue as well (to serialize resource usage)
      return _imageQueue.enqueue<String>(imagePath, (path) async {
        final ocrText = _simulateOCRText(path);
        return ocrText;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error in OCR extraction: $e');
      return '';
    }
  }

  /// Unified image processing pipeline
  Future<ImageProcessingResult> processImage(String imagePath) async {
    // ignore: avoid_print
    print('Processing image pipeline: $imagePath');
    
    final stopwatch = Stopwatch()..start();
    
    // Step 1: Classify image type
    final imageType = await classifyImageType(imagePath);
    
    // Step 2: Process based on type
    String? caption;
    List<DetectedRegion> regions = [];
    String ocrText = '';
    List<String> extractedConcepts = [];
    
    if (imageType == 'labeled') {
      // For labeled images: Extract OCR text
      ocrText = await extractOCRText(imagePath);
      extractedConcepts = _extractConceptsFromOCR(ocrText);
    } else if (imageType == 'plain') {
      // For plain images: Generate caption
      caption = await generateCaption(imagePath);
      extractedConcepts = _extractConceptsFromCaption(caption);
    } else {
      // For diagrams/flowcharts/etc: Detect regions and generate caption
      regions = await detectRegions(imagePath);
      caption = await generateCaption(imagePath);
      extractedConcepts = _extractConceptsFromRegions(regions);
    }
    
    stopwatch.stop();
    
    return ImageProcessingResult(
      imageType: imageType,
      caption: caption ?? '',
      regions: regions,
      ocrText: ocrText,
      extractedConcepts: extractedConcepts,
      processingTime: stopwatch.elapsedMilliseconds,
    );
  }

  /// Process multiple images in batch
  Future<List<ImageProcessingResult>> processImagesBatch(List<String> imagePaths) async {
    final results = <ImageProcessingResult>[];
    
    // Process in parallel with limited concurrency
    final batches = _chunkList(imagePaths, 3); // Process 3 at a time
    
    for (final batch in batches) {
      final batchResults = await Future.wait(
        batch.map((path) => processImage(path))
      );
      results.addAll(batchResults);
    }
    
    return results;
  }

  // queueImageProcessing() removed — use ImageProcessingQueue directly via imageQueueProvider


  // Helper methods for simulation/demonstration
  String _simulateClassification(String fileName) {
    if (fileName.contains('diagram') || fileName.contains('schema')) return 'diagram';
    if (fileName.contains('organ') || fileName.contains('body')) return 'organ';
    if (fileName.contains('flow') || fileName.contains('process')) return 'flowchart';
    if (fileName.contains('chart') || fileName.contains('graph')) return 'chart';
    if (fileName.contains('table') || fileName.contains('data')) return 'table';
    if (fileName.contains('map') || fileName.contains('geography')) return 'map';
    if (fileName.contains('labeled') || fileName.contains('annotated')) return 'labeled';
    return 'plain';
  }

  List<DetectedRegion> _simulateDetections(String imageType) {
    final regions = <DetectedRegion>[];
    final random = Random();
    
    if (imageType == 'diagram') {
      regions.addAll([
        DetectedRegion(
          label: 'component',
          confidence: random.nextDouble() * 0.2 + 0.8,
          boundingBox: Rect(left: 0.2, top: 0.3, right: 0.4, bottom: 0.5),
          attributes: ['electronic', 'circuit'],
        ),
        DetectedRegion(
          label: 'connection',
          confidence: random.nextDouble() * 0.2 + 0.7,
          boundingBox: Rect(left: 0.5, top: 0.4, right: 0.7, bottom: 0.6),
          attributes: ['wire', 'link'],
        ),
      ]);
    } else if (imageType == 'organ') {
      regions.addAll([
        DetectedRegion(
          label: 'heart',
          confidence: random.nextDouble() * 0.2 + 0.85,
          boundingBox: Rect(left: 0.3, top: 0.2, right: 0.6, bottom: 0.5),
          attributes: ['cardiovascular', 'muscle'],
        ),
        DetectedRegion(
          label: 'artery',
          confidence: random.nextDouble() * 0.2 + 0.75,
          boundingBox: Rect(left: 0.1, top: 0.4, right: 0.3, bottom: 0.6),
          attributes: ['blood vessel', 'circulation'],
        ),
      ]);
    } else if (imageType == 'flowchart') {
      regions.addAll([
        DetectedRegion(
          label: 'decision',
          confidence: random.nextDouble() * 0.2 + 0.8,
          boundingBox: Rect(left: 0.4, top: 0.3, right: 0.6, bottom: 0.5),
          attributes: ['choice', 'branch'],
        ),
        DetectedRegion(
          label: 'process',
          confidence: random.nextDouble() * 0.2 + 0.7,
          boundingBox: Rect(left: 0.2, top: 0.6, right: 0.8, bottom: 0.8),
          attributes: ['action', 'step'],
        ),
      ]);
    }
    
    return regions;
  }

  String _generateSimulatedCaption(String imagePath, String imageType) {
    final baseCaptions = {
      'diagram': 'Technical diagram showing system components and connections.',
      'organ': 'Anatomical illustration of human organ with labeled parts.',
      'flowchart': 'Process flowchart illustrating workflow and decision points.',
      'plain': 'Educational image demonstrating key concepts visually.',
      'labeled': 'Annotated diagram with explanatory text and labels.',
      'chart': 'Data visualization chart showing trends and comparisons.',
      'graph': 'Mathematical graph plotting relationships between variables.',
      'table': 'Organized data table presenting information systematically.',
      'map': 'Geographical map showing locations and spatial relationships.',
      'illustration': 'Visual representation of concepts for educational purposes.',
    };
    
    final baseCaption = baseCaptions[imageType] ?? 'Educational image for learning.';
    final enhancements = [
      'Useful for understanding complex topics.',
      'Helps visualize abstract concepts.',
      'Supports multimedia learning approach.',
      'Enhances comprehension through visual aids.',
    ];
    
    final random = Random();
    final enhancement = enhancements[random.nextInt(enhancements.length)];
    
    return '$baseCaption $enhancement';
  }

  String _simulateOCRText(String imagePath) {
    final ocrExamples = [
      'Figure 1: The human circulatory system consists of heart, arteries, and veins.',
      'Table 2.1: Comparison of different learning methodologies and their effectiveness.',
      'Equation: E = mc² represents the relationship between energy and mass.',
      'Diagram labels: Input → Process → Output → Feedback → Repeat',
      'Chart title: Student Performance Trends 2020-2025 showing steady improvement.',
    ];
    
    final random = Random();
    return ocrExamples[random.nextInt(ocrExamples.length)];
  }

  List<String> _extractConceptsFromOCR(String ocrText) {
    final concepts = <String>[];
    
    // Simple concept extraction from OCR text
    final keywords = ['system', 'heart', 'artery', 'vein', 'equation', 'energy', 
                     'mass', 'input', 'process', 'output', 'feedback', 'performance',
                     'trend', 'improvement', 'comparison', 'methodology', 'effectiveness'];
    
    for (final keyword in keywords) {
      if (ocrText.toLowerCase().contains(keyword)) {
        concepts.add(keyword);
      }
    }
    
    return concepts.take(5).toList(); // Limit to 5 concepts
  }

  List<String> _extractConceptsFromCaption(String caption) {
    final concepts = <String>[];
    
    // Extract nouns and important words from caption
    final words = caption.toLowerCase().split(' ');
    final importantWords = ['diagram', 'system', 'component', 'connection', 'anatomical',
                           'illustration', 'organ', 'process', 'flowchart', 'workflow',
                           'decision', 'visualization', 'chart', 'data', 'trend',
                           'mathematical', 'graph', 'relationship', 'table', 'organized',
                           'geographical', 'map', 'spatial', 'concept', 'educational'];
    
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^a-z]'), '');
      if (importantWords.contains(cleanWord) && !concepts.contains(cleanWord)) {
        concepts.add(cleanWord);
      }
    }
    
    return concepts.take(5).toList(); // Limit to 5 concepts
  }

  List<String> _extractConceptsFromRegions(List<DetectedRegion> regions) {
    final concepts = <String>{};
    
    for (final region in regions) {
      concepts.add(region.label);
      concepts.addAll(region.attributes);
    }
    
    return concepts.take(5).toList(); // Limit to 5 concepts
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  void dispose() {
    _classifierInterpreter?.close();
    _detectorInterpreter?.close();
    // _captionSession?.dispose();
    _loaded = false;
  }

  /// Get service status
  Map<String, dynamic> getStatus() {
    return {
      'classifierLoaded': _classifierInterpreter != null,
      'detectorLoaded': _detectorInterpreter != null,
      'captionModelLoaded': _captionSession != null,
      'isLoaded': _loaded,
    };
  }
}

/// Image processing result
class ImageProcessingResult {
  final String imageType;
  final String caption;
  final List<DetectedRegion> regions;
  final String ocrText;
  final List<String> extractedConcepts;
  final int processingTime; // milliseconds

  ImageProcessingResult({
    required this.imageType,
    required this.caption,
    required this.regions,
    required this.ocrText,
    required this.extractedConcepts,
    required this.processingTime,
  });

  @override
  String toString() {
    return 'ImageProcessingResult(type: $imageType, caption: "${caption.length > 30 ? '${caption.substring(0, 30)}...' : caption}", regions: ${regions.length}, concepts: ${extractedConcepts.length}, time: ${processingTime}ms)';
  }
}

/// Image processing task for queue
class ImageProcessingTask {
  final String imagePath;
  final Function(ImageProcessingResult) onComplete;
  final Function(Object)? onError;

  ImageProcessingTask({
    required this.imagePath,
    required this.onComplete,
    this.onError,
  });
}

// Uses dart:collection Queue.
