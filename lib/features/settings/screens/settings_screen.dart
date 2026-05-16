import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../ai/nlp/embedding_providers.dart';
import '../../../ai/router/ai_router.dart';
import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/data_providers.dart';
import '../settings_models.dart';
import '../settings_prefs.dart';
import '../../../services/sync/federated_sync_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _manifestAsset = 'assets/models/model_manifest.json';

  AiModePreference _mode = AiModePreference.offlineOnly;

  final _geminiController = TextEditingController();
  final _groqController = TextEditingController();
  bool _showGemini = false;
  bool _showGroq = false;

  String? _geminiTest;
  String? _groqTest;

  ModelManifest? _manifest;
  String? _manifestError;

  PackageInfo? _packageInfo;
  String? _flutterVersion;
  int? _cacheCount;
  int? _dbBytes;
  int? _assetsBytes;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _groqController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final mode = await SettingsPrefs.getAiMode();
    final gemini = await SettingsPrefs.getGeminiApiKey();
    final groq = await SettingsPrefs.getGroqApiKey();

    ModelManifest? manifest;
    String? manifestError;
    try {
      final raw = await rootBundle.loadString(_manifestAsset);
      manifest = ModelManifest.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (e) {
      manifestError = '$e';
    }

    PackageInfo? p;
    try {
      p = await PackageInfo.fromPlatform();
    } catch (_) {}

    String? flutterV;
    try {
      flutterV = (await rootBundle.loadString('flutter_version.txt')).trim();
      if (flutterV.isEmpty) flutterV = 'unknown';
    } catch (_) {
      flutterV = 'unknown';
    }

    if (!mounted) return;
    setState(() {
      _mode = mode;
      _geminiController.text = gemini ?? '';
      _groqController.text = groq ?? '';
      _manifest = manifest;
      _manifestError = manifestError;
      _packageInfo = p;
      _flutterVersion = flutterV;
    });

    await _refreshStorageAndCache();
  }

  Future<void> _refreshStorageAndCache() async {
    final cache = ref.read(cacheRepositoryProvider);

    int? cacheCount;
    int? dbBytes;
    int? assetsBytes;

    try {
      cacheCount = await cache.count();
    } catch (_) {}

    try {
      final dirs = <Directory>[];
      try {
        dirs.add(await getApplicationDocumentsDirectory());
      } catch (_) {}
      try {
        dirs.add(await getApplicationSupportDirectory());
      } catch (_) {}
      var sum = 0;
      for (final d in dirs) {
        if (!d.existsSync()) continue;
        await for (final e in d.list(recursive: true, followLinks: false)) {
          if (e is File && e.path.toLowerCase().contains('learngrid')) {
            sum += await e.length();
          }
        }
      }
      dbBytes = sum;
    } catch (_) {}

    try {
      final manifest = _manifest;
      if (manifest != null) {
        var sum = 0;
        for (final m in manifest.models.values) {
          final p = m.primaryAssetPath;
          try {
            final bd = await rootBundle.load(p);
            sum += bd.lengthInBytes;
          } catch (_) {}
        }
        assetsBytes = sum;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _cacheCount = cacheCount;
      _dbBytes = dbBytes;
      _assetsBytes = assetsBytes;
    });
  }

  Future<void> _setMode(AiModePreference next) async {
    setState(() => _mode = next);
    await SettingsPrefs.setAiMode(next);
  }

  String? _validateGemini(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('AIza')) return null;
    return 'Expected Gemini key to start with AIza';
  }

  String? _validateGroq(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('gsk_')) return null;
    return 'Expected Groq key to start with gsk_';
  }

  Future<void> _saveGemini() async {
    final v = _geminiController.text;
    final err = _validateGemini(v);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await SettingsPrefs.setGeminiApiKey(v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gemini key saved')));
  }

  Future<void> _saveGroq() async {
    final v = _groqController.text;
    final err = _validateGroq(v);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await SettingsPrefs.setGroqApiKey(v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Groq key saved')));
  }

  Future<void> _testGemini() async {
    final v = _geminiController.text.trim();
    final err = _validateGemini(v);
    if (err != null) {
      setState(() => _geminiTest = 'Failed ✗ (invalid key)');
      return;
    }
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$v');
    try {
      final resp = await http.get(uri);
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      setState(() => _geminiTest = ok ? 'Connected ✓' : 'Failed ✗ (${resp.statusCode})');
    } catch (e) {
      setState(() => _geminiTest = 'Failed ✗ ($e)');
    }
  }

  Future<void> _testGroq() async {
    final v = _groqController.text.trim();
    final err = _validateGroq(v);
    if (err != null) {
      setState(() => _groqTest = 'Failed ✗ (invalid key)');
      return;
    }
    final uri = Uri.parse('https://api.groq.com/openai/v1/models');
    try {
      final resp = await http.get(uri, headers: {'Authorization': 'Bearer $v'});
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      setState(() => _groqTest = ok ? 'Connected ✓' : 'Failed ✗ (${resp.statusCode})');
    } catch (e) {
      setState(() => _groqTest = 'Failed ✗ ($e)');
    }
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isPlaceholder(ModelEntry m) {
    final size = m.sizeMb ?? ((m.sizeKb ?? 0) / 1024);
    if (size <= 0) return true;
    final sha = (m.sha256 ?? '').toLowerCase();
    if (sha.isEmpty || sha == 'placeholder') return true;
    final st = (m.status ?? '').toLowerCase();
    if (st.contains('placeholder')) return true;
    return false;
  }

  Future<void> _showDownloadInstructions(String modelKey) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Download Missing Models'),
          content: const Text(
            'To download models into assets/models, run:\n\npython scripts/download_models.py\n\nThis MVP build shows instructions instead of invoking Python directly from Flutter.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        );
      },
    );
  }

  Future<bool> _confirm(String title, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
          ],
        );
      },
    );
    return ok ?? false;
  }

  Future<void> _clearAiCache() async {
    final ok = await _confirm('Clear AI Response Cache', 'Delete all AIResponseCache rows?');
    if (!ok) return;
    await ref.read(cacheRepositoryProvider).clearAll();
    await _refreshStorageAndCache();
  }

  Future<void> _clearEmbeddings() async {
    final ok = await _confirm('Clear Embeddings', 'Delete all Embeddings rows? This forces reindex.');
    if (!ok) return;
    await ref.read(embeddingRepositoryProvider).clearAll();
    await ref.read(embeddingServiceProvider).rebuildIndex();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Embedding index cleared and rebuilt')),
    );
    await _refreshStorageAndCache();
  }

  String _fmtBytes(int? bytes) {
    if (bytes == null) return 'Unknown';
    const k = 1024;
    if (bytes < k) return '$bytes B';
    if (bytes < k * k) return '${(bytes / k).toStringAsFixed(1)} KB';
    if (bytes < k * k * k) return '${(bytes / (k * k)).toStringAsFixed(1)} MB';
    return '${(bytes / (k * k * k)).toStringAsFixed(1)} GB';
  }

  Future<void> _exportProgress() async {
    final userId = ref.read(currentUserIdProvider);
    final progressRepo = ref.read(progressRepositoryProvider);
    final engagementRepo = ref.read(engagementRepositoryProvider);

    final progress = await progressRepo.getAllByUser(userId);
    final sessions = await engagementRepo.getUserSessions(userId);

    final json = jsonEncode({
      'exported_at': DateTime.now().toIso8601String(),
      'user_id': userId,
      'progress': progress
          .map((p) => {
                'id': p.id,
                'content_id': p.contentId,
                'completion_pct': p.completionPct,
                'last_accessed_at': p.lastAccessedAt,
                'difficulty_rating': p.difficultyRating,
                'time_spent_seconds': p.timeSpentSeconds,
              })
          .toList(growable: false),
      'engagement_sessions': sessions
          .map((s) => {
                'id': s.id,
                'content_id': s.contentId,
                'state': s.state,
                'duration_seconds': s.durationSeconds,
                'tap_count': s.tapCount,
                'scroll_events': s.scrollEvents,
                'idle_seconds': s.idleSeconds,
                'started_at': s.startedAt,
              })
          .toList(growable: false),
    });

    final fileName = 'learngrid_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final res = await FilePicker.platform.saveFile(
      dialogTitle: 'Export my data',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (!mounted) return;
    if (res == null) return;
    final file = File(res);
    await file.writeAsString(json, flush: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $res')));
  }

  @override
  Widget build(BuildContext context) {
    final aiRouter = ref.read(aiRouterProvider);
    final manifest = _manifest;
    final models = manifest?.models.entries.toList(growable: false) ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('AI Mode', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SegmentedButton<AiModePreference>(
            segments: const [
              ButtonSegment(value: AiModePreference.offlineOnly, label: Text('Offline Only')),
              ButtonSegment(value: AiModePreference.askEachTime, label: Text('Ask Each Time')),
              ButtonSegment(value: AiModePreference.alwaysCloud, label: Text('Always Use Cloud')),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => _setMode(s.first),
          ),
          const SizedBox(height: 20),

          Text('API Keys', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _geminiController,
            obscureText: !_showGemini,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              helperText: 'Encrypted at rest (flutter_secure_storage).',
              suffixIcon: IconButton(
                tooltip: _showGemini ? 'Hide' : 'Show',
                onPressed: () => setState(() => _showGemini = !_showGemini),
                icon: Icon(_showGemini ? Icons.visibility_off : Icons.visibility),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(onPressed: _saveGemini, child: const Text('Save')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _testGemini, child: const Text('Test connection')),
              const SizedBox(width: 12),
              Expanded(child: Text(_geminiTest ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _groqController,
            obscureText: !_showGroq,
            decoration: InputDecoration(
              labelText: 'Groq API Key',
              helperText: 'Encrypted at rest (flutter_secure_storage).',
              suffixIcon: IconButton(
                tooltip: _showGroq ? 'Hide' : 'Show',
                onPressed: () => setState(() => _showGroq = !_showGroq),
                icon: Icon(_showGroq ? Icons.visibility_off : Icons.visibility),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(onPressed: _saveGroq, child: const Text('Save')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _testGroq, child: const Text('Test connection')),
              const SizedBox(width: 12),
              Expanded(child: Text(_groqTest ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 20),

          Text('Model Status', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_manifestError != null)
            Text('Manifest error: $_manifestError', style: TextStyle(color: Theme.of(context).colorScheme.error))
          else if (manifest == null)
            const Text('No manifest loaded.')
          else
            ...models.map((e) {
              final key = e.key;
              final m = e.value;
              final size = (m.sizeMb != null)
                  ? '${m.sizeMb!.toStringAsFixed(2)} MB'
                  : (m.sizeKb != null)
                      ? '${m.sizeKb!.toStringAsFixed(2)} KB'
                      : 'Unknown';
              final version = manifest.metadata.version ?? 'unknown';
              final isPlaceholder = _isPlaceholder(m);
              return Card(
                child: FutureBuilder<bool>(
                  future: _assetExists(m.primaryAssetPath),
                  builder: (context, snapshot) {
                    final exists = snapshot.data ?? false;
                    final status = (!exists || isPlaceholder) ? 'missing' : 'loaded';
                    return ListTile(
                      title: Text(key),
                      subtitle: Text('$size • $status • v$version'),
                      trailing: status == 'loaded'
                          ? const Icon(Icons.check_circle_outline)
                          : TextButton(
                              onPressed: () => _showDownloadInstructions(key),
                              child: const Text('Download missing models'),
                            ),
                    );
                  },
                ),
              );
            }),
          const SizedBox(height: 20),

          Text('Federated Learning', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, child) {
              final syncStateAsync = ref.watch(flSyncStateProvider);
              final syncState = syncStateAsync.valueOrNull ?? const FLSyncState();
              final statusText = syncState.status.name.toUpperCase();
              final lastSync = syncState.lastSyncAt?.toLocal().toString() ?? 'Never';
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sync Status: $statusText', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (syncState.status == FLSyncStatus.running)
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Last Sync: $lastSync'),
                      if (syncState.errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text('Error: ${syncState.errorMessage}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                      if (syncState.gradientBytesTransmitted != null) ...[
                        const SizedBox(height: 4),
                        Text('Transmitted: ${_fmtBytes(syncState.gradientBytesTransmitted)}'),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: syncState.status == FLSyncStatus.running
                            ? null
                            : () => ref.read(federatedSyncProvider).forceSync(),
                        child: const Text('Force Sync Now'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          Text('Storage & Cache', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DB size: ${_fmtBytes(_dbBytes)}'),
                  Text(
                    'Cached responses count: ${((_cacheCount ?? -1) < 0) ? 'Unknown' : '$_cacheCount'}',
                  ),
                  Text('Total assets size: ${_fmtBytes(_assetsBytes)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton(onPressed: _clearAiCache, child: const Text('Clear AI response cache')),
                      const SizedBox(width: 12),
                      OutlinedButton(onPressed: _clearEmbeddings, child: const Text('Clear embeddings')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _refreshStorageAndCache, child: const Text('Refresh')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Export Progress', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FilledButton(onPressed: _exportProgress, child: const Text('Export my data')),
          const SizedBox(height: 20),

          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App version: ${_packageInfo?.version ?? 'Unknown'} (${_packageInfo?.buildNumber ?? '-'})'),
                  Text('Flutter version: ${_flutterVersion ?? 'unknown'}'),
                  Text('Active ONNX runtime: ${manifest?.metadata.runtime ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Text('AI router: ${aiRouter.runtimeType}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
