import '../../data/models/entities.dart';

/// Rule-based MVP recommender.
///
/// ML scoring can be added later behind the same interface.
class RecommendationService {
  const RecommendationService();

  List<ContentItemEntity> recommend({
    required List<ContentItemEntity> all,
    required String? currentContentId,
    required String engagementState,
    required Map<String, UserProgressEntity> progressByContent,
    int limit = 3,
  }) {
    if (all.isEmpty) return const [];
    ContentItemEntity? current;
    if (currentContentId != null) {
      for (final item in all) {
        if (item.id == currentContentId) {
          current = item;
          break;
        }
      }
    }

    final baseDifficulty = current?.difficultyLevel ?? 2;
    final baseSubject = current?.subject;

    Iterable<ContentItemEntity> candidates = all;
    if (baseSubject != null) {
      candidates = candidates.where((e) => e.subject == baseSubject);
    }

    if (engagementState == 'fatigued') {
      final target = (baseDifficulty - 1).clamp(1, 5);
      candidates = candidates.where((e) => e.difficultyLevel <= target);
    } else if (engagementState == 'focused') {
      final target = (baseDifficulty + 1).clamp(1, 5);
      candidates = candidates.where((e) => e.difficultyLevel <= target);
    }

    // Prefer not-yet-completed.
    final scored = candidates.map((item) {
      final p = progressByContent[item.id];
      final completion = p?.completionPct ?? 0.0;
      final score = (1.0 - completion) * 100 + (item.addedAt / 1000000000000.0);
      return (score: score, item: item);
    }).toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));

    final out = <ContentItemEntity>[];
    for (final s in scored) {
      if (currentContentId != null && s.item.id == currentContentId) continue;
      out.add(s.item);
      if (out.length >= limit) break;
    }
    return out;
  }
}
