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
  static const String accessKeyId = '9fe04d2a045f903579a9b9e91165579f';
  static const String secretAccessKey = '58f2f76726477227468a7a070b812952fb48a7b215d1f717b62100121fb906aa';

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
