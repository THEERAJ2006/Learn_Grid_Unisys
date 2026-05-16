import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recommendation_service.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return const RecommendationService();
});
