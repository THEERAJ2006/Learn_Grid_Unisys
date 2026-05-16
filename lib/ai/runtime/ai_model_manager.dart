import 'dart:async';

import 'package:flutter/foundation.dart';
import '../nlp/embedding_service.dart';
import '../speech/whisper_service.dart';
import '../vision/image_service.dart';
import '../../data/repositories/repository_interfaces.dart';
import 'onnx_inference_service.dart';

/// Manages lazy loading and caching of AI models.
class AIModelManager {
  AIModelManager._privateConstructor();
  static final AIModelManager _instance = AIModelManager._privateConstructor();
  factory AIModelManager() => _instance;

  // Model instances
  EmbeddingService? _embeddingService;
  WhisperService? _whisperService;
  ImageService? _imageService;

  // Loading states (public-facing flags; services manage their own _loaded internally)
  bool _embeddingLoading = false;
  bool _whisperLoading = false;
  bool _imageLoading = false;

  // Load timers for auto-unload
  Timer? _embeddingUnloadTimer;
  Timer? _whisperUnloadTimer;
  Timer? _imageUnloadTimer;

  static const Duration _modelUnloadDelay = Duration(minutes: 5);

  /// Initialize embedding service with repository and optional ONNX backend.
  void initialize({
    required EmbeddingRepository embeddingRepository,
    OnnxInferenceService? onnxService,
  }) {
    _embeddingService = EmbeddingService(
      embeddings: embeddingRepository,
      onnx: onnxService,
    );
  }

  /// Get embedding service (lazy loads if needed).
  Future<EmbeddingService> get embeddingService async {
    if (_embeddingService == null) {
      throw StateError('EmbeddingService not initialized. Call initialize() first.');
    }
    await _loadEmbeddingModel();
    _resetUnloadTimer(_embeddingUnloadTimer, _unloadEmbeddingModel);
    return _embeddingService!;
  }

  /// Get whisper service (lazy loads if needed).
  Future<WhisperService> get whisperService async {
    _whisperService ??= WhisperService();
    await _loadWhisperModel();
    _resetUnloadTimer(_whisperUnloadTimer, _unloadWhisperModel);
    return _whisperService!;
  }

  /// Get image service (lazy loads if needed).
  Future<ImageService> get imageService async {
    _imageService ??= ImageService();
    await _loadImageModel();
    _resetUnloadTimer(_imageUnloadTimer, _unloadImageModel);
    return _imageService!;
  }

  // Private loading methods
  Future<void> _loadEmbeddingModel() async {
    if (_embeddingLoading) return;
    _embeddingLoading = true;
    try {
      await _embeddingService!.initialize();
    } finally {
      _embeddingLoading = false;
    }
  }

  Future<void> _loadWhisperModel() async {
    if (_whisperLoading) return;
    _whisperLoading = true;
    try {
      await _whisperService!.initialize();
    } finally {
      _whisperLoading = false;
    }
  }

  Future<void> _loadImageModel() async {
    if (_imageLoading) return;
    _imageLoading = true;
    try {
      await _imageService!.initialize();
    } finally {
      _imageLoading = false;
    }
  }

  // Private unload methods — release resources without accessing private fields.
  Future<void> _unloadEmbeddingModel() async {
    _embeddingService = null;
    debugPrint('[AIModelManager] EmbeddingService unloaded');
  }

  Future<void> _unloadWhisperModel() async {
    _whisperService = null;
    debugPrint('[AIModelManager] WhisperService unloaded');
  }

  Future<void> _unloadImageModel() async {
    _imageService?.dispose();
    _imageService = null;
    debugPrint('[AIModelManager] ImageService unloaded');
  }

  // Timer management
  void _resetUnloadTimer(Timer? timer, Future<void> Function() callback) {
    timer?.cancel();
    timer = Timer(_modelUnloadDelay, () => callback());
  }

  /// Manually unload all models to free memory.
  Future<void> unloadAll() async {
    await Future.wait([
      _unloadEmbeddingModel(),
      _unloadWhisperModel(),
      _unloadImageModel(),
    ]);

    _embeddingUnloadTimer?.cancel();
    _whisperUnloadTimer?.cancel();
    _imageUnloadTimer?.cancel();
  }

  /// Get current model loading status.
  Map<String, bool> get loadingStatus => {
        'embedding': _embeddingLoading,
        'whisper': _whisperLoading,
        'image': _imageLoading,
      };

  /// Get current model loaded status.
  Map<String, bool> get loadedStatus => {
        'embedding': _embeddingService != null,
        'whisper': _whisperService != null,
        'image': _imageService != null,
      };
}
