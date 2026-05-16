class ModelManifest {
  final Map<String, ModelEntry> models;
  final ManifestMetadata metadata;

  const ModelManifest({required this.models, required this.metadata});

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    final modelsJson = (json['models'] as Map?)?.cast<String, dynamic>() ?? const {};
    final models = <String, ModelEntry>{
      for (final e in modelsJson.entries)
        e.key: ModelEntry.fromJson((e.value as Map).cast<String, dynamic>()),
    };
    final metaJson = (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ModelManifest(
      models: models,
      metadata: ManifestMetadata.fromJson(metaJson),
    );
  }
}

class ModelEntry {
  final String file;
  final String format;
  final double? sizeMb;
  final double? sizeKb;
  final String? sha256;
  final String? source;
  final String? description;
  final String? status;
  final List<ModelFileEntry> files;
  final int? totalBytes;

  const ModelEntry({
    required this.file,
    required this.format,
    this.sizeMb,
    this.sizeKb,
    this.sha256,
    this.source,
    this.description,
    this.status,
    this.files = const [],
    this.totalBytes,
  });

  factory ModelEntry.fromJson(Map<String, dynamic> json) {
    final filesJson = (json['files'] as List?)
            ?.whereType<Map>()
            .map((entry) => ModelFileEntry.fromJson(entry.cast<String, dynamic>()))
            .toList(growable: false) ??
        const <ModelFileEntry>[];
    final firstFile = filesJson.isNotEmpty ? filesJson.first : null;
    final totalBytes = (json['total_bytes'] as num?)?.toInt() ?? firstFile?.bytes;

    return ModelEntry(
      file: (json['file'] as String?) ?? firstFile?.fileName ?? firstFile?.path ?? '',
      format: (json['format'] as String?) ?? _inferFormat((json['file'] as String?) ?? firstFile?.path),
      sizeMb: (json['size_mb'] is num)
          ? (json['size_mb'] as num).toDouble()
          : (totalBytes == null ? null : totalBytes / (1024 * 1024)),
      sizeKb: (json['size_kb'] is num) ? (json['size_kb'] as num).toDouble() : null,
      sha256: json['sha256'] as String? ?? firstFile?.sha256,
      source: json['source'] as String? ?? json['source_url'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? (filesJson.isEmpty ? 'missing' : 'downloaded'),
      files: filesJson,
      totalBytes: totalBytes,
    );
  }

  String get primaryAssetPath {
    if (files.isNotEmpty) {
      return files.first.path;
    }
    return file.startsWith('assets/') ? file : 'assets/models/$file';
  }
}

class ModelFileEntry {
  final String path;
  final int bytes;
  final String? sha256;

  const ModelFileEntry({
    required this.path,
    required this.bytes,
    this.sha256,
  });

  factory ModelFileEntry.fromJson(Map<String, dynamic> json) {
    return ModelFileEntry(
      path: (json['path'] as String?) ?? '',
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      sha256: json['sha256'] as String?,
    );
  }

  String get fileName {
    final parts = path.split('/');
    return parts.isEmpty ? path : parts.last;
  }
}

class ManifestMetadata {
  final String? version;
  final String? createdAt;
  final String? platform;
  final String? runtime;

  const ManifestMetadata({this.version, this.createdAt, this.platform, this.runtime});

  factory ManifestMetadata.fromJson(Map<String, dynamic> json) {
    return ManifestMetadata(
      version: json['version'] as String?,
      createdAt: json['created_at'] as String?,
      platform: json['platform'] as String?,
      runtime: json['runtime'] as String? ?? json['generated_by'] as String?,
    );
  }
}

String _inferFormat(String? path) {
  final lower = path?.toLowerCase() ?? '';
  if (lower.endsWith('.onnx')) return 'onnx';
  if (lower.endsWith('.tflite')) return 'tflite';
  if (lower.endsWith('.txt')) return 'text';
  if (lower.endsWith('.json')) return 'json';
  return 'unknown';
}
