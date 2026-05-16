import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../ai/nlp/embedding_providers.dart';
import '../../ai/nlp/embedding_service.dart';
import '../../ai/vision/image_service.dart';
import '../../data/models/entities.dart';
import '../../data/providers/data_providers.dart';
import '../../data/repositories/repository_interfaces.dart';

class FileService {
  FileService({
    required this.fileRepository,
    required this.embeddingService,
  });

  final FileManagementRepository fileRepository;
  final EmbeddingService embeddingService;
  final ImageService _imageService = ImageService();
  final _uuid = const Uuid();

  Future<ManagedFileEntity> processAndStore(File rawFile) async {
    final docs = await getApplicationDocumentsDirectory();
    final storageDir = Directory(p.join(docs.path, 'learngrid_files'));
    if (!storageDir.existsSync()) {
      await storageDir.create(recursive: true);
    }

    final ext = p.extension(rawFile.path).toLowerCase();
    final fileType = _detectType(ext);
    final safeName = p.basename(rawFile.path);
    final storedName = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}_$safeName';
    final storedPath = p.join(storageDir.path, storedName);
    final copied = await rawFile.copy(storedPath);

    final extracted = await _extractText(copied, fileType);
    final preview = _preview(extracted);
    final thumbnailPath = await _thumbnailFor(copied, fileType, safeName);

    final inserted = await fileRepository.insertFile(
      ManagedFileEntity(
        id: 0,
        name: safeName,
        fileType: fileType,
        localPath: copied.path,
        sizeBytes: await copied.length(),
        uploadedAt: DateTime.now().millisecondsSinceEpoch,
        extractedTextPreview: preview,
        thumbnailPath: thumbnailPath,
        embeddingCount: 0,
      ),
    );

    if (extracted.trim().isNotEmpty) {
      final embeddingCount = await embeddingService.ensureFileEmbeddings(
        fileId: inserted.id,
        plainText: extracted,
      );
      await fileRepository.updateEmbeddingCount(inserted.id, embeddingCount);
    }

    final refreshed = await fileRepository.getFileById(inserted.id);
    return refreshed ?? inserted;
  }

  Future<ManagedFileEntity> processAndStoreBytes(String name, Uint8List bytes) async {
    final ext = p.extension(name).toLowerCase();
    final fileType = _detectType(ext);
    final safeName = p.basename(name);
    
    // On web, we cannot use local paths effectively with dart:io.
    // Store a dummy URI.
    final storedPath = 'memory://${_uuid.v4()}_$safeName';

    // Extract text from bytes
    final extracted = await _extractTextFromBytes(bytes, fileType, name);
    final preview = _preview(extracted);

    final inserted = await fileRepository.insertFile(
      ManagedFileEntity(
        id: 0,
        name: safeName,
        fileType: fileType,
        localPath: storedPath,
        sizeBytes: bytes.length,
        uploadedAt: DateTime.now().millisecondsSinceEpoch,
        extractedTextPreview: preview,
        thumbnailPath: null, // No thumbnails generated for web right now
        embeddingCount: 0,
      ),
    );

    if (extracted.trim().isNotEmpty) {
      final embeddingCount = await embeddingService.ensureFileEmbeddings(
        fileId: inserted.id,
        plainText: extracted,
      );
      await fileRepository.updateEmbeddingCount(inserted.id, embeddingCount);
    }

    final refreshed = await fileRepository.getFileById(inserted.id);
    return refreshed ?? inserted;
  }

  Future<void> deleteFile(int fileId) async {
    final file = await fileRepository.getFileById(fileId);
    if (file != null && !kIsWeb) {
      // dart:io is not available on web — skip physical file deletion.
      final physical = File(file.localPath);
      if (physical.existsSync()) {
        await physical.delete();
      }
      if (file.thumbnailPath != null && file.thumbnailPath != file.localPath) {
        final thumb = File(file.thumbnailPath!);
        if (thumb.existsSync()) {
          await thumb.delete();
        }
      }
    }
    await fileRepository.deleteFile(fileId);
  }

  String _detectType(String ext) {
    switch (ext) {
      case '.pdf':
        return 'pdf';
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.webp':
      case '.gif':
        return 'image';
      case '.txt':
      case '.md':
      case '.csv':
        return 'txt';
      default:
        return 'txt';
    }
  }

  Future<String> _extractText(File file, String fileType) async {
    switch (fileType) {
      case 'image':
        try {
          final result = await _imageService.processImage(file.path);
          return [
            result.caption,
            result.ocrText,
            result.extractedConcepts.join(' '),
          ].where((s) => s.trim().isNotEmpty).join('\n');
        } catch (_) {
          return '';
        }
      case 'pdf':
        return _extractPdfText(await file.readAsBytes());
      case 'txt':
      default:
        return file.readAsString();
    }
  }

  Future<String> _extractTextFromBytes(Uint8List bytes, String fileType, String name) async {
    switch (fileType) {
      case 'image':
        try {
          // processImage in simulation mode just checks the filename/path string.
          final result = await _imageService.processImage(name);
          return [
            result.caption,
            result.ocrText,
            result.extractedConcepts.join(' '),
          ].where((s) => s.trim().isNotEmpty).join('\n');
        } catch (_) {
          return '';
        }
      case 'pdf':
        return _extractPdfText(bytes);
      case 'txt':
      default:
        return utf8.decode(bytes, allowMalformed: true);
    }
  }

  String _extractPdfText(List<int> bytes) {
    final text = latin1.decode(bytes, allowInvalid: true);
    final pdfStrings = RegExp(r'\(([^()]{3,})\)').allMatches(text).map((m) => m.group(1)?.trim() ?? '').where((s) => s.isNotEmpty);
    final printable = pdfStrings.join(' ');
    if (printable.trim().isNotEmpty) {
      return printable.replaceAll(RegExp(r'\s+'), ' ');
    }
    return text.replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E]+'), ' ').replaceAll(RegExp(r'\s+'), ' ');
  }

  String _preview(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 300) return normalized;
    return normalized.substring(0, 300);
  }

  Future<String?> _thumbnailFor(File file, String fileType, String title) async {
    if (fileType == 'image') return file.path;
    if (fileType != 'pdf') return null;

    final docs = await getApplicationDocumentsDirectory();
    final thumbDir = Directory(p.join(docs.path, 'learngrid_thumbnails'));
    if (!thumbDir.existsSync()) {
      await thumbDir.create(recursive: true);
    }

    final out = File(p.join(thumbDir.path, '${file.path.hashCode}.png'));
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(512, 288);
    final rect = ui.Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = const LinearGradient(
      colors: [Color(0xFFFFE0E0), Color(0xFFFFF4F4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(28)), paint);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFE85D04);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(10), const Radius.circular(24)), outline);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'PDF',
        style: const TextStyle(
          color: Color(0xFFE85D04),
          fontSize: 74,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    )..layout(maxWidth: size.width);
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, 70));

    final namePainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Color(0xFF4A2C2A),
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
      ),
    )..layout(maxWidth: size.width - 48);
    namePainter.paint(canvas, Offset((size.width - namePainter.width) / 2, 170));

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    await out.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return out.path;
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService(
    fileRepository: ref.watch(fileRepositoryProvider),
    embeddingService: ref.watch(embeddingServiceProvider),
  );
});
