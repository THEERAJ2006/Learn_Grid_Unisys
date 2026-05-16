import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/entities.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/repositories/repository_interfaces.dart';

typedef ContentState = AsyncValue<List<ContentItemEntity>>;

final contentNotifierProvider =
    AsyncNotifierProvider<ContentNotifier, List<ContentItemEntity>>(
  ContentNotifier.new,
);

final contentByTypeProvider =
    Provider.family<List<ContentItemEntity>, String>((ref, type) {
  final items = ref.watch(contentNotifierProvider).valueOrNull ?? const [];
  return items.where((e) => e.type == type).toList(growable: false);
});

final contentBySubjectProvider =
    Provider.family<List<ContentItemEntity>, String>((ref, subject) {
  final items = ref.watch(contentNotifierProvider).valueOrNull ?? const [];
  return items.where((e) => (e.subject ?? '') == subject).toList(growable: false);
});

final contentByDifficultyProvider =
    Provider.family<List<ContentItemEntity>, int>((ref, difficulty) {
  final items = ref.watch(contentNotifierProvider).valueOrNull ?? const [];
  return items
      .where((e) => e.difficultyLevel == difficulty)
      .toList(growable: false);
});

final contentByIdProvider =
    Provider.family<ContentItemEntity?, String>((ref, id) {
  final items = ref.watch(contentNotifierProvider).valueOrNull ?? const [];
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
});

class ContentNotifier extends AsyncNotifier<List<ContentItemEntity>> {
  late final ContentRepository _repo;
  final _uuid = const Uuid();

  @override
  Future<List<ContentItemEntity>> build() async {
    _repo = ref.watch(contentRepositoryProvider);
    final existing = await _repo.getAllContent();
    if (existing.isNotEmpty) return existing;

    // Seed a minimal offline dataset so the dashboard isn't empty on first run.
    final now = DateTime.now().millisecondsSinceEpoch;
    const seedPath = 'assets/content/offline_getting_started.txt';
    final seeds = <ContentItemEntity>[
      ContentItemEntity(
        id: _uuid.v4(),
        title: 'Offline: Getting Started',
        type: 'text',
        filePath: seedPath,
        difficultyLevel: 1,
        topicTags: '["offline","getting-started"]',
        subject: 'General',
        language: 'en',
        fileSize: null,
        addedAt: now,
      ),
      ContentItemEntity(
        id: _uuid.v4(),
        title: 'Offline: Study Technique (Spaced Repetition)',
        type: 'text',
        filePath: seedPath,
        difficultyLevel: 2,
        topicTags: '["study","spaced-repetition"]',
        subject: 'General',
        language: 'en',
        fileSize: null,
        addedAt: now,
      ),
      ContentItemEntity(
        id: _uuid.v4(),
        title: 'Offline: Notes Template',
        type: 'text',
        filePath: seedPath,
        difficultyLevel: 3,
        topicTags: '["notes","template"]',
        subject: 'General',
        language: 'en',
        fileSize: null,
        addedAt: now,
      ),
    ];
    await _repo.insertBulk(seeds);
    return _repo.getAllContent();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.getAllContent);
  }

  Future<void> insert(ContentItemEntity item) async {
    await _repo.insert(item);
    await refresh();
  }

  Future<void> updateItem(ContentItemEntity item) async {
    await _repo.update(item);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await refresh();
  }

  Future<void> seedSample() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = ContentItemEntity(
      id: _uuid.v4(),
      title: 'Sample Content #${DateTime.now().second}',
      type: 'text',
      filePath: 'assets/content/offline_getting_started.txt',
      difficultyLevel: (DateTime.now().second % 5) + 1,
      topicTags: '["sample"]',
      subject: 'Science',
      language: 'en',
      fileSize: 1024,
      addedAt: now,
    );
    await _repo.insert(item);
    await refresh();
  }
}
