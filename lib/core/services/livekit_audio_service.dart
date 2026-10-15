import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/livekit_config.dart';
import 'livekit_token_service.dart';

/// Callback signatures for LiveKit audio events
typedef ActiveSpeakersCallback = void Function(List<Participant> speakers);
typedef ConnectionStateCallback = void Function(ConnectionState state);

/// Service to manage real-time WebRTC audio rooms via LiveKit.
class LiveKitAudioService {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  ActiveSpeakersCallback? onActiveSpeakersChanged;
  ConnectionStateCallback? onConnectionStateChanged;
  VoidCallback? onRoomDisconnected;

  bool _isMicEnabled = false;
  bool get isMicEnabled => _isMicEnabled;

  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  String? _currentRoomId;
  String? get currentRoomId => _currentRoomId;

  /// Connect to a LiveKit room as an audio participant.
  Future<bool> connect({
    required String roomId,
    required String userId,
    required String userName,
  }) async {
    try {
      // Disconnect any existing room
      await disconnect();

      _currentRoomId = roomId;

      // 1. Generate JWT token with publish and subscribe rights
      final token = LiveKitTokenService.generateRoomToken(
        roomName: roomId,
        participantIdentity: userId,
        participantName: userName,
        canPublish: true,
        canSubscribe: true,
      );

      // 2. Instantiate LiveKit room with optimized audio options
      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: AudioPublishOptions(
            dtx: true,
          ),
        ),
      );

      // 3. Attach listeners
      _listener = _room!.createListener();
      _listener!
        ..on<ActiveSpeakersChangedEvent>((event) {
          onActiveSpeakersChanged?.call(event.speakers);
        })
        ..on<RoomDisconnectedEvent>((event) {
          _isMicEnabled = false;
          onRoomDisconnected?.call();
        });

      // 4. Connect to LiveKit Cloud / Server
      await _room!.connect(
        LiveKitConfig.url,
        token,
        fastConnectOptions: FastConnectOptions(
          microphone: const TrackOption(enabled: false),
        ),
      );

      _isMicEnabled = false;
      return true;
    } catch (e) {
      debugPrint('[LiveKitAudioService] Connection failed: $e');
      return false;
    }
  }

  /// Request microphone permission and publish local audio track (taking a seat).
  Future<bool> enableMicrophone() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('[LiveKitAudioService] Microphone permission not granted');
        return false;
      }

      if (_room == null || !isConnected) {
        debugPrint('[LiveKitAudioService] Room not connected');
        return false;
      }

      await _room!.localParticipant?.setMicrophoneEnabled(true);
      _isMicEnabled = true;
      return true;
    } catch (e) {
      debugPrint('[LiveKitAudioService] Failed to enable microphone: $e');
      return false;
    }
  }

  /// Mute or unmute the local microphone.
  Future<void> setMicrophoneMuted(bool muted) async {
    try {
      if (_room == null || !isConnected) return;
      await _room!.localParticipant?.setMicrophoneEnabled(!muted);
      _isMicEnabled = !muted;
    } catch (e) {
      debugPrint('[LiveKitAudioService] Failed to set microphone state: $e');
    }
  }

  /// Disable microphone when leaving a speaker seat.
  Future<void> disableMicrophone() async {
    try {
      if (_room == null || !isConnected) return;
      await _room!.localParticipant?.setMicrophoneEnabled(false);
      _isMicEnabled = false;
    } catch (e) {
      debugPrint('[LiveKitAudioService] Failed to disable microphone: $e');
    }
  }

  /// Disconnect and release audio resources.
  Future<void> disconnect() async {
    try {
      _isMicEnabled = false;
      _currentRoomId = null;
      await _listener?.dispose();
      _listener = null;
      await _room?.disconnect();
      await _room?.dispose();
      _room = null;
    } catch (e) {
      debugPrint('[LiveKitAudioService] Error during disconnect: $e');
    }
  }
}
