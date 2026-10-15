/// Configuration for LiveKit WebRTC Voice Streaming.
/// 
/// When moving to your self-hosted VPS server in the future,
/// simply change [url] to your VPS domain (e.g., 'wss://rtc.royalchatlive.com')
/// and update [apiKey] and [apiSecret].
class LiveKitConfig {
  LiveKitConfig._();

  /// LiveKit WebRTC WebSocket URL
  static const String url = 'wss://royal-chat-live-a78egp07.livekit.cloud';

  /// LiveKit API Key
  static const String apiKey = 'APImSdrocERdGX4';

  /// LiveKit API Secret (used to sign JWT access tokens)
  static const String apiSecret = 'VM8CroEHxuyYVXtiOeeSQt1KDh5f6owMLMkwUVpn4RvB';
}
