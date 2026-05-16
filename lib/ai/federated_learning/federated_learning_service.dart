import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// ── Federated Learning Protocol ──────────────────────────────────────────────

/// Represents a model update (gradients or weights) from a local training step.
class ModelUpdate {
  final String modelId;
  final int round;
  final List<double> gradients; // Flattened gradient vector
  final int trainingExamples;   // Number of examples used in local training
  final DateTime timestamp;

  ModelUpdate({
    required this.modelId,
    required this.round,
    required this.gradients,
    required this.trainingExamples,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Serialize to bytes for transmission
  Uint8List toBytes() {
    final buffer = BytesBuilder();
    // Header: modelId length + modelId + round + trainingExamples
    final idBytes = modelId.codeUnits;
    buffer.addByte(idBytes.length);
    buffer.add(idBytes);
    
    // 4 bytes: round
    final roundBytes = _intToBytes(round);
    buffer.add(roundBytes);
    
    // 4 bytes: trainingExamples
    final examplesBytes = _intToBytes(trainingExamples);
    buffer.add(examplesBytes);
    
    // Gradients: 4 bytes count + double values (8 bytes each)
    final gradCount = _intToBytes(gradients.length);
    buffer.add(gradCount);
    for (final grad in gradients) {
      buffer.add(_doubleToBytes(grad));
    }
    
    return buffer.toBytes();
  }

  /// Deserialize from bytes
  static ModelUpdate fromBytes(Uint8List data) {
    var offset = 0;
    
    // Read modelId
    final idLen = data[offset];
    offset++;
    final modelId = String.fromCharCodes(data.sublist(offset, offset + idLen));
    offset += idLen;
    
    // Read round
    final round = _bytesToInt(data.sublist(offset, offset + 4));
    offset += 4;
    
    // Read trainingExamples
    final trainingExamples = _bytesToInt(data.sublist(offset, offset + 4));
    offset += 4;
    
    // Read gradients
    final gradCount = _bytesToInt(data.sublist(offset, offset + 4));
    offset += 4;
    final gradients = <double>[];
    for (int i = 0; i < gradCount; i++) {
      gradients.add(_bytesToDouble(data.sublist(offset, offset + 8)));
      offset += 8;
    }
    
    return ModelUpdate(
      modelId: modelId,
      round: round,
      gradients: gradients,
      trainingExamples: trainingExamples,
    );
  }

  static List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  static int _bytesToInt(Uint8List bytes) {
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }

  static List<int> _doubleToBytes(double value) {
    final bits = value.toStringAsFixed(20).codeUnits;
    return [bits.length, ...bits];
  }

  static double _bytesToDouble(Uint8List bytes) {
    final len = bytes[0];
    final str = String.fromCharCodes(bytes.sublist(1, 1 + len));
    return double.parse(str);
  }
}

// ── Differential Privacy ─────────────────────────────────────────────────────

/// Differential privacy mechanism using Gaussian noise.
class DifferentialPrivacy {
  final double epsilon;        // Privacy budget (0.1 = high privacy, 10 = low privacy)
  final double delta;          // Failure probability (typically 1e-6)
  final double l2Sensitivity;  // Maximum l2 norm of gradients (clipping bound)

  DifferentialPrivacy({
    required this.epsilon,
    required this.delta,
    required this.l2Sensitivity,
  });

  /// Clip gradients to bound sensitivity
  List<double> clipGradients(List<double> gradients) {
    final norm = _computeL2Norm(gradients);
    if (norm <= l2Sensitivity) return gradients;
    
    final scale = l2Sensitivity / norm;
    return gradients.map((g) => g * scale).toList();
  }

  /// Add Gaussian noise for differential privacy
  List<double> addNoise(List<double> gradients) {
    final clipped = clipGradients(gradients);
    final sigma = _computeSigma();
    final random = Random();
    
      return clipped.map((gradient) {
        // Box-Muller transform for Gaussian noise
        final u1 = random.nextDouble();
        final u2 = random.nextDouble();
        final z = sqrt(-2.0 * log(u1 == 0 ? 1e-10 : u1)) * cos(2 * pi * u2);
        return gradient + sigma * z;
      }).toList();
  }

  double _computeL2Norm(List<double> gradients) {
    var sum = 0.0;
    for (final g in gradients) {
      sum += g * g;
    }
    return sqrt(sum);
  }

  double _computeSigma() {
    // Standard DP-SGD noise calculation
    // sigma = sqrt(2 * log(1.25 / delta)) / epsilon * l2Sensitivity
    final logTerm = log(1.25 / delta);
    return sqrt(2.0 * logTerm) / epsilon * l2Sensitivity;
  }
}

// ── Federated Learning Client ────────────────────────────────────────────────

enum FLEventType {
  localTrainingStarted,
  localTrainingComplete,
  gradientComputed,
  noiseAdded,
  updateSent,
  globalModelReceived,
  aggregationComplete,
  error,
}

class FLEvent {
  final FLEventType type;
  final String? modelId;
  final int? round;
  final double? accuracy;     // Local accuracy after training
  final String? errorMessage;
  final List<double>? gradients;

  const FLEvent({
    required this.type,
    this.modelId,
    this.round,
    this.accuracy,
    this.errorMessage,
    this.gradients,
  });
}

/// Federated Learning Client Service
/// Handles local model training and communication with FL server
abstract class FederatedLearningClient {
  Stream<FLEvent> get events;
  
  /// Initialize with device ID and model configuration
  Future<void> init({
    required String deviceId,
    required String modelId,
    required int inputDim,
    required int outputDim,
    bool enablePrivacy = true,
  });
  
  /// Train local model with provided data
  /// Returns local accuracy metric
  Future<double> trainLocal({
    required List<List<double>> features,
    required List<int> labels,
    int epochs = 5,
    double learningRate = 0.01,
  });
  
  /// Compute gradient update from local training
  Future<List<double>> computeGradientUpdate();
  
  /// Apply differential privacy to gradients
  Future<List<double>> applyDifferentialPrivacy(List<double> gradients);
  
  /// Send local update to peers or aggregator
  Future<void> sendUpdate(String peerId, ModelUpdate update);
  
  /// Receive and apply global model update
  Future<void> receiveGlobalUpdate(ModelUpdate globalUpdate);
  
  /// Get current model weights
  Future<List<double>> getModelWeights();
  
  /// Set model weights (for receiving global updates)
  Future<void> setModelWeights(List<double> weights);
  
  void dispose();
}

/// In-memory implementation of federated learning client
class InMemoryFLClient implements FederatedLearningClient {
  final _eventCtrl = StreamController<FLEvent>.broadcast();
  late String _modelId;
  late int _inputDim;
  late int _outputDim;
  late bool _enablePrivacy;
  late DifferentialPrivacy _dpMechanism;
  
  List<double> _weights = [];
  List<double> _lastGradients = [];
  int _round = 0;

  @override
  Stream<FLEvent> get events => _eventCtrl.stream;

  @override
  Future<void> init({
    required String deviceId,
    required String modelId,
    required int inputDim,
    required int outputDim,
    bool enablePrivacy = true,
  }) async {
    _modelId = modelId;
    _inputDim = inputDim;
    _outputDim = outputDim;
    _enablePrivacy = enablePrivacy;
    
    // Initialize DP mechanism
    _dpMechanism = DifferentialPrivacy(
      epsilon: 1.0,        // Medium privacy
      delta: 1e-6,
      l2Sensitivity: 10.0, // Gradient clipping bound
    );
    
    // Initialize random weights
    final random = Random();
    _weights = List.generate(
      (_inputDim + 1) * _outputDim,
      (_) => (random.nextDouble() - 0.5) * 0.01,
    );
    
    debugPrint('[FL Client] Initialized for model=$_modelId, dim=$_inputDim→$_outputDim');
  }

  @override
  Future<double> trainLocal({
    required List<List<double>> features,
    required List<int> labels,
    int epochs = 5,
    double learningRate = 0.01,
  }) async {
    _emit(FLEvent(
      type: FLEventType.localTrainingStarted,
      modelId: _modelId,
      round: _round,
    ));

    try {
      double accuracy = 0.0;
      
      // Simple stochastic gradient descent
      for (int epoch = 0; epoch < epochs; epoch++) {
        var correctCount = 0;
        var totalCount = 0;
        
        for (int i = 0; i < features.length; i++) {
          final output = _predict(features[i]);
          final predicted = _argmax(output);
          final actual = labels[i];
          
          if (predicted == actual) correctCount++;
          totalCount++;
          
          // Compute loss gradient
          final gradient = _computeGradient(features[i], actual, output);
          
          // Update weights
          for (int j = 0; j < _weights.length && j < gradient.length; j++) {
            _weights[j] -= learningRate * gradient[j];
          }
          
          _lastGradients = gradient;
        }
        
        accuracy = correctCount / totalCount;
      }
      
      _round++;
      
      _emit(FLEvent(
        type: FLEventType.localTrainingComplete,
        modelId: _modelId,
        round: _round,
        accuracy: accuracy,
      ));
      
      return accuracy;
    } catch (e) {
      _emit(FLEvent(
        type: FLEventType.error,
        errorMessage: 'Training error: $e',
      ));
      rethrow;
    }
  }

  @override
  Future<List<double>> computeGradientUpdate() async {
    _emit(FLEvent(
      type: FLEventType.gradientComputed,
      modelId: _modelId,
      gradients: _lastGradients,
    ));
    return _lastGradients;
  }

  @override
  Future<List<double>> applyDifferentialPrivacy(List<double> gradients) async {
    if (!_enablePrivacy) return gradients;
    
    final noisyGradients = _dpMechanism.addNoise(gradients);
    
    _emit(FLEvent(
      type: FLEventType.noiseAdded,
      modelId: _modelId,
      gradients: noisyGradients,
    ));
    
    return noisyGradients;
  }

  @override
  Future<void> sendUpdate(String peerId, ModelUpdate update) async {
    debugPrint('[FL Client] Sending update to $peerId for round ${update.round}');
    _emit(FLEvent(
      type: FLEventType.updateSent,
      modelId: update.modelId,
      round: update.round,
    ));
  }

  @override
  Future<void> receiveGlobalUpdate(ModelUpdate globalUpdate) async {
    _weights = globalUpdate.gradients;
    _round = globalUpdate.round;
    
    _emit(FLEvent(
      type: FLEventType.globalModelReceived,
      modelId: globalUpdate.modelId,
      round: globalUpdate.round,
    ));
    
    debugPrint('[FL Client] Received global update for round ${globalUpdate.round}');
  }

  @override
  Future<List<double>> getModelWeights() async => _weights.toList();

  @override
  Future<void> setModelWeights(List<double> weights) async {
    _weights = weights;
  }

  /// Simple linear model prediction
  List<double> _predict(List<double> features) {
    final output = List<double>.filled(_outputDim, 0.0);
    var idx = 0;
    
    for (int i = 0; i < _outputDim; i++) {
      for (int j = 0; j < _inputDim; j++) {
        if (idx < _weights.length) {
          output[i] += features[j] * _weights[idx];
          idx++;
        }
      }
      // Bias term
      if (idx < _weights.length) {
        output[i] += _weights[idx];
        idx++;
      }
    }
    
    return _softmax(output);
  }

  /// Softmax activation
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((l) => exp(l - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  /// Gradient computation (simplified cross-entropy)
  List<double> _computeGradient(
    List<double> features,
    int label,
    List<double> predictions,
  ) {
    final gradient = List<double>.filled(_weights.length, 0.0);
    var idx = 0;
    
    for (int i = 0; i < _outputDim; i++) {
      final target = i == label ? 1.0 : 0.0;
      final error = predictions[i] - target;
      
      for (int j = 0; j < _inputDim; j++) {
        if (idx < gradient.length) {
          gradient[idx] += error * features[j];
          idx++;
        }
      }
      if (idx < gradient.length) {
        gradient[idx] += error;
        idx++;
      }
    }
    
    return gradient;
  }

  int _argmax(List<double> values) {
    var maxIdx = 0;
    var maxVal = values[0];
    for (int i = 1; i < values.length; i++) {
      if (values[i] > maxVal) {
        maxVal = values[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  void _emit(FLEvent event) {
    if (!_eventCtrl.isClosed) _eventCtrl.add(event);
  }

  @override
  void dispose() {
    _eventCtrl.close();
  }
}

// Stub implementations for alternative platforms
class WebFLClient implements FederatedLearningClient {
  @override
  Stream<FLEvent> get events => const Stream.empty();

  @override
  Future<void> init({
    required String deviceId,
    required String modelId,
    required int inputDim,
    required int outputDim,
    bool enablePrivacy = true,
  }) async {
    throw UnsupportedError('FL not available on web');
  }

  @override
  Future<double> trainLocal({
    required List<List<double>> features,
    required List<int> labels,
    int epochs = 5,
    double learningRate = 0.01,
  }) async =>
      throw UnsupportedError('FL not available on web');

  @override
  Future<List<double>> computeGradientUpdate() async =>
      throw UnsupportedError('FL not available on web');

  @override
  Future<List<double>> applyDifferentialPrivacy(List<double> gradients) async =>
      throw UnsupportedError('FL not available on web');

  @override
  Future<void> sendUpdate(String peerId, ModelUpdate update) async =>
      throw UnsupportedError('FL not available on web');

  @override
  Future<void> receiveGlobalUpdate(ModelUpdate globalUpdate) async =>
      throw UnsupportedError('FL not available on web');

  @override
  Future<List<double>> getModelWeights() async =>
      throw UnsupportedError('FL not available on web');

  @override
  Future<void> setModelWeights(List<double> weights) async =>
      throw UnsupportedError('FL not available on web');

  @override
  void dispose() {}
}
