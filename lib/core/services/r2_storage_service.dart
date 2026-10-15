import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';
import '../config/r2_config.dart';

/// Service to handle file uploads and CDN asset retrieval via Cloudflare R2 Object Storage.
class R2StorageService {
  R2StorageService._();
  static final R2StorageService instance = R2StorageService._();

  Minio? _minioClient;

  Minio? get _client {
    if (!R2Config.isConfigured) return null;
    _minioClient ??= Minio(
      endPoint: R2Config.endPoint,
      accessKey: R2Config.accessKeyId,
      secretKey: R2Config.secretAccessKey,
      useSSL: true,
      region: 'auto',
    );
    return _minioClient;
  }

  /// Uploads raw bytes to Cloudflare R2 bucket and returns the public CDN URL.
  Future<String?> uploadBytes({
    required Uint8List bytes,
    required String path,
    String contentType = 'image/jpeg',
  }) async {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    if (!R2Config.isConfigured || _client == null) {
      debugPrint('[R2StorageService] R2 credentials not configured. Using public URL placeholder: ${R2Config.getPublicUrl(cleanPath)}');
      return R2Config.getPublicUrl(cleanPath);
    }

    try {
      final stream = Stream<Uint8List>.value(bytes);
      await _client!.putObject(
        R2Config.bucketName,
        cleanPath,
        stream,
        size: bytes.length,
        metadata: {'Content-Type': contentType},
      );

      final publicUrl = R2Config.getPublicUrl(cleanPath);
      debugPrint('[R2StorageService] Uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[R2StorageService] Upload error: $e');
      return null;
    }
  }

  /// Uploads user profile avatar to Cloudflare R2: `avatars/<userId>_<timestamp>.<ext>`
  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String userId,
    String extension = 'jpg',
  }) async {
    final fileName = 'avatars/${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return uploadBytes(bytes: bytes, path: fileName, contentType: 'image/$extension');
  }

  /// Uploads moments feed photo to Cloudflare R2: `moments/<userId>_<timestamp>.<ext>`
  Future<String?> uploadMomentPhoto({
    required Uint8List bytes,
    required String userId,
    String extension = 'jpg',
  }) async {
    final fileName = 'moments/${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return uploadBytes(bytes: bytes, path: fileName, contentType: 'image/$extension');
  }

  /// Uploads room cover banner to Cloudflare R2: `rooms/<roomId>_<timestamp>.<ext>`
  Future<String?> uploadRoomCover({
    required Uint8List bytes,
    required String roomId,
    String extension = 'jpg',
  }) async {
    final fileName = 'rooms/${roomId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return uploadBytes(bytes: bytes, path: fileName, contentType: 'image/$extension');
  }
}
