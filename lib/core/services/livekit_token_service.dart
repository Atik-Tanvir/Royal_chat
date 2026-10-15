import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/livekit_config.dart';

/// Service to generate JWT access tokens for connecting to LiveKit WebRTC rooms.
class LiveKitTokenService {
  LiveKitTokenService._();

  /// Generates a signed LiveKit JWT Access Token for joining a voice room.
  ///
  /// [roomName]: Identifier of the voice chat room.
  /// [participantIdentity]: Unique identity for the participant (e.g. user ID).
  /// [participantName]: Display name of the user.
  /// [canPublish]: Whether the participant can stream their microphone.
  /// [canSubscribe]: Whether the participant can listen to other audio streams.
  static String generateRoomToken({
    required String roomName,
    required String participantIdentity,
    required String participantName,
    bool canPublish = false,
    bool canSubscribe = true,
  }) {
    final jwt = JWT(
      {
        'name': participantName,
        'video': {
          'room': roomName,
          'roomJoin': true,
          'canPublish': canPublish,
          'canSubscribe': canSubscribe,
          'canPublishData': true,
        },
      },
      issuer: LiveKitConfig.apiKey,
      subject: participantIdentity,
    );

    // Sign with HS256 algorithm using the API Secret
    return jwt.sign(
      SecretKey(LiveKitConfig.apiSecret),
      expiresIn: const Duration(hours: 24),
    );
  }
}
