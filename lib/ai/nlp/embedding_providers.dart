import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
import 'embedding_service.dart';

final embeddingServiceProvider = Provider<EmbeddingService>((ref) {
  return EmbeddingService(embeddings: ref.watch(embeddingRepositoryProvider));
});
