import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/entities.dart';
import '../../data/providers/data_providers.dart';

enum FileViewMode { grid, list }

final fileFilterProvider = StateProvider<String>((ref) => 'all');
final fileSortProvider = StateProvider<String>((ref) => 'recent');
final fileViewModeProvider =
    StateProvider<FileViewMode>((ref) => FileViewMode.grid);
final fileSearchQueryProvider = StateProvider<String>((ref) => '');

final managedFilesProvider = StreamProvider<List<ManagedFileEntity>>((ref) {
  final filter = ref.watch(fileFilterProvider);
  final sort = ref.watch(fileSortProvider);
  return ref
      .watch(fileRepositoryProvider)
      .watchAllFiles(filterType: filter, sortBy: sort);
});

final fileByIdProvider =
    FutureProvider.family<ManagedFileEntity?, int>((ref, id) {
  return ref.watch(fileRepositoryProvider).getFileById(id);
});
