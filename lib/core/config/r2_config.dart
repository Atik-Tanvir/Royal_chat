/// Configuration for Cloudflare R2 Object Storage.
/// 
/// Account ID: c6c6c97eea5025ec4aca78fa9e80c60d
/// Bucket: royal-chat-live
/// Public CDN URL: https://pub-24addd4f2203427489399f391ba11669.r2.dev
class R2Config {
  R2Config._();

  static const String accountId = 'c6c6c97eea5025ec4aca78fa9e80c60d';
  static const String bucketName = 'royal-chat-live';
  static const String endPoint = 'c6c6c97eea5025ec4aca78fa9e80c60d.r2.cloudflarestorage.com';
  static const String publicDevUrl = 'https://pub-24addd4f2203427489399f391ba11669.r2.dev';

  /// R2 API Token credentials (Access Key ID and Secret Access Key)
  /// Created in Cloudflare Dashboard -> R2 -> Manage R2 API Tokens
  static const String accessKeyId = 'YOUR_R2_ACCESS_KEY_ID';
  static const String secretAccessKey = 'YOUR_R2_SECRET_ACCESS_KEY';

  /// Whether credentials have been configured
  static bool get isConfigured =>
      accessKeyId.isNotEmpty &&
      secretAccessKey.isNotEmpty &&
      accessKeyId != 'YOUR_R2_ACCESS_KEY_ID';

  /// Constructs the full public CDN URL for an object stored in R2.
  static String getPublicUrl(String key) {
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return key;
    }
    final cleanKey = key.startsWith('/') ? key.substring(1) : key;
    return '$publicDevUrl/$cleanKey';
  }
}
