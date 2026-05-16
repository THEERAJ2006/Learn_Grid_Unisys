import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'federated_learning_service.dart';

// ── Federated Learning Providers ─────────────────────────────────────────────

final flClientProvider = Provider<FederatedLearningClient>((ref) {
  final client = InMemoryFLClient();
  ref.onDispose(client.dispose);
  return client;
});

/// Stream of FL events
final flEventsProvider = StreamProvider<FLEvent>((ref) {
  final client = ref.watch(flClientProvider);
  return client.events;
});

/// Current FL round number
final flRoundProvider = StateProvider<int>((ref) => 0);

/// Current model weights
final flModelWeightsProvider = FutureProvider<List<double>>((ref) async {
  final client = ref.watch(flClientProvider);
  return client.getModelWeights();
});

/// Local training accuracy from last round
final flLocalAccuracyProvider = StateProvider<double?>((ref) => null);

/// Whether differential privacy is enabled
final flPrivacyEnabledProvider = StateProvider<bool>((ref) => true);

/// Privacy epsilon value (privacy budget)
final flEpsilonProvider = StateProvider<double>((ref) => 1.0);
