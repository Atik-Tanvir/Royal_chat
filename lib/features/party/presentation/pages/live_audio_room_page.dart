import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/livekit_audio_service.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../domain/entities/party_room.dart';
import '../widgets/lucky_race_game_drawer.dart';
import '../../../games/presentation/pages/bucket_prediction_game_page.dart';
import '../widgets/user_profile_popover.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';
import '../../../chat/presentation/pages/conversation_page.dart';
import '../../../chat/domain/entities/chat_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/domain/entities/wallet_transaction.dart';
import '../../../../core/services/wallet_transaction_service.dart';

class LiveAudioRoomPage extends StatefulWidget {
  final PartyRoom room;

  const LiveAudioRoomPage({super.key, required this.room});

  @override
  State<LiveAudioRoomPage> createState() => _LiveAudioRoomPageState();
}

class _LiveAudioRoomPageState extends State<LiveAudioRoomPage> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  bool _isVideoLiveMode = false;
  int? _pendingSeatRequestIndex;
  Timer? _seatRequestTimer;
  final LiveKitAudioService _audioService = LiveKitAudioService();
  bool _isConnectingAudio = false;
  bool _isAudioConnected = false;
  int? _mySeatIndex;

  bool _isMicMuted = true;
  bool _isFollowing = false;
  String? _activeGiftBanner;
  Timer? _giftBannerTimer;

  // PK Battle State
  bool _isPkBattleActive = false;
  int _pkSecondsLeft = 300;
  Timer? _pkTimer;
  int _blueScore = 450;
  int _redScore = 720;

  // Host Stage Request Approval State
  Map<String, dynamic>? _incomingSeatRequest;

  // 8 seats: Index 0 is Host, Indices 1-7 are Guests
  late List<Map<String, dynamic>> _seats;
  RealtimeChannel? _roomChannel;

  final List<Map<String, String>> _messages = [];
  final TextEditingController _msgController = TextEditingController();

  String get _hostUserId {
    if (_seats.isNotEmpty) {
      final uid = _seats[0]['userId']?.toString() ?? '';
      if (uid.isNotEmpty) return uid;
    }
    return '';
  }

  bool get _isHost {
    final profile = context.read<ProfileBloc>().state.profile;
    if (_mySeatIndex == 0) return true;
    if (widget.room.hostName.toLowerCase() == profile.nickname.toLowerCase()) return true;
    if (_hostUserId.isNotEmpty && AuthSessionManager.currentUserId == _hostUserId) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _seats = [
      {
        'index': 0,
        'userId': null,
        'name': widget.room.hostName,
        'avatar': widget.room.hostAvatar,
        'isHost': true,
        'isMuted': false,
        'isSpeaking': true,
      },
      for (int i = 1; i < 8; i++)
        {
          'index': i,
          'userId': null,
          'name': null,
          'avatar': null,
          'isHost': false,
          'isMuted': false,
          'isSpeaking': false,
        },
    ];

    if (widget.room.category == 'PK') {
      _isPkBattleActive = true;
      _startPkTimer();
    }

    _messages.add({
      'sender': 'System',
      'text': 'Welcome to ${widget.room.title}! Live WebRTC audio connected.',
    });

    _initLiveKit();
    _loadSeatsFromSupabase();
    _initRealtimeSubscription();
  }

  void _togglePkBattle() {
    setState(() {
      _isPkBattleActive = !_isPkBattleActive;
      if (_isPkBattleActive) {
        _pkSecondsLeft = 300;
        _startPkTimer();
        _sendMessage('⚔️ Host started a 5-minute 1v1 PK Duel Battle! Send gifts to support!');
        _displayGiftBanner('⚔️ 1v1 PK Duel Started! 05:00 Time War!');
      } else {
        _pkTimer?.cancel();
        _sendMessage('🏁 PK Battle concluded!');
        _displayGiftBanner('🏁 PK Battle concluded!');
      }
    });
  }

  void _startPkTimer() {
    _pkTimer?.cancel();
    _pkTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_pkSecondsLeft > 0) {
        if (mounted) setState(() => _pkSecondsLeft--);
      } else {
        t.cancel();
        if (mounted) {
          setState(() => _isPkBattleActive = false);
          _sendMessage('🏁 PK Battle Time is UP! Winner: ${_redScore >= _blueScore ? "RED Team" : "BLUE Team"}! 🏆');
        }
      }
    });
  }

  Future<void> _loadSeatsFromSupabase() async {
    try {
      final response = await SupabaseConfig.client
          .from('room_seats')
          .select()
          .eq('room_id', widget.room.id)
          .order('seat_index', ascending: true);

      if (response.isNotEmpty && mounted) {
        setState(() {
          final currentUserId = AuthSessionManager.currentUserId;
          for (var row in response as List) {
            final idx = (row['seat_index'] as num?)?.toInt() ?? 0;
            if (idx >= 0 && idx < _seats.length) {
              final uid = row['user_id']?.toString() ?? '';
              final uName = row['user_name']?.toString() ?? '';
              final uAvatar = row['avatar_url']?.toString() ?? '';
              final isMuted = row['is_muted'] as bool? ?? false;

              if (uid.isNotEmpty) {
                _seats[idx]['userId'] = uid;
                _seats[idx]['name'] = uName.isNotEmpty ? uName : (idx == 0 ? widget.room.hostName : 'Guest');
                _seats[idx]['avatar'] = uAvatar.isNotEmpty ? uAvatar : (idx == 0 ? widget.room.hostAvatar : null);
                _seats[idx]['isMuted'] = isMuted;

                if (currentUserId != null && uid == currentUserId) {
                  _mySeatIndex = idx;
                  _isMicMuted = isMuted;
                }
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('[LiveAudioRoom] Error loading room seats: $e');
    }
  }

  void _initRealtimeSubscription() {
    try {
      _roomChannel = SupabaseConfig.client
          .channel('room_${widget.room.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'room_seats',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: widget.room.id,
            ),
            callback: (payload) {
              _handleSeatChange(payload);
            },
          )
          .onBroadcast(
            event: 'chat',
            callback: (payload) {
              if (!mounted) return;
              final sender = payload['sender']?.toString() ?? 'User';
              final text = payload['text']?.toString() ?? '';
              if (text.isNotEmpty) {
                setState(() {
                  _messages.add({'sender': sender, 'text': text});
                });
              }
            },
          )
          .onBroadcast(
            event: 'gift',
            callback: (payload) {
              if (!mounted) return;
              final sender = payload['sender']?.toString() ?? 'User';
              final giftName = payload['giftName']?.toString() ?? 'Gift';
              final giftIcon = payload['giftIcon']?.toString() ?? '🎁';
              final cost = (payload['cost'] as num?)?.toInt() ?? 0;
              _displayGiftBanner('✨ $sender gifted $giftIcon $giftName to Host! (+$cost Charm)');
              setState(() {
                _messages.add({
                  'sender': '👑 $sender',
                  'text': 'sent $giftIcon $giftName to Host',
                });
              });

              // If current user is host, refresh profile to reflect credited diamonds
              if (_hostUserId.isNotEmpty && AuthSessionManager.currentUserId == _hostUserId) {
                context.read<ProfileBloc>().add(LoadUserProfileEvent());
              }
            },
          )
          .onBroadcast(
            event: 'seat_request',
            callback: (payload) {
              if (!mounted) return;
              final user = payload['userName']?.toString() ?? 'User';
              final sIdx = (payload['seatIndex'] as num?)?.toInt() ?? 0;
              final uid = payload['userId']?.toString() ?? '';
              final avatar = payload['avatar']?.toString() ?? '';
              _displayGiftBanner('🙋 $user requested Mic Seat ${sIdx + 1}');
              setState(() {
                _incomingSeatRequest = {
                  'user': user,
                  'seatIndex': sIdx,
                  'userId': uid,
                  'avatar': avatar,
                };
                _messages.add({
                  'sender': '📢 Request',
                  'text': '$user requested Mic Seat ${sIdx + 1}',
                });
              });
            },
          )
          .onBroadcast(
            event: 'seat_approved',
            callback: (payload) {
              if (!mounted) return;
              final sIdx = (payload['seatIndex'] as num?)?.toInt() ?? 0;
              final uid = payload['userId']?.toString() ?? '';
              final uName = payload['userName']?.toString() ?? 'User';
              if (uid == AuthSessionManager.currentUserId) {
                _takeSeat(sIdx);
              } else {
                setState(() {
                  if (sIdx >= 0 && sIdx < _seats.length) {
                    _seats[sIdx]['userId'] = uid;
                    _seats[sIdx]['name'] = uName;
                    _seats[sIdx]['isSpeaking'] = true;
                  }
                });
              }
            },
          )
          .onBroadcast(
            event: 'live_request',
            callback: (payload) {
              if (!mounted) return;
              final user = payload['userName']?.toString() ?? 'User';
              final type = payload['type']?.toString() ?? 'Co-Host';
              _displayGiftBanner('📡 $user requested $type from Host!');
              setState(() {
                _messages.add({
                  'sender': '📡 Live Request',
                  'text': '$user requested $type',
                });
              });
            },
          )
          .onBroadcast(
            event: 'game_invite',
            callback: (payload) {
              if (!mounted) return;
              final sender = payload['sender']?.toString() ?? 'Someone';
              final game = payload['game']?.toString() ?? 'Game';
              _displayGiftBanner('🎮 $sender invited everyone to $game!');
              setState(() {
                _messages.add({
                  'sender': '🎮 Challenge',
                  'text': '$sender invites all to $game! Tap Game icon to play!',
                });
              });
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[LiveAudioRoom] Realtime subscription error: $e');
    }
  }

  void _handleSeatChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final newRecord = payload.newRecord;
    if (newRecord.isEmpty) return;

    final idx = (newRecord['seat_index'] as num?)?.toInt();
    if (idx == null || idx < 0 || idx >= _seats.length) return;

    final uid = newRecord['user_id']?.toString() ?? '';
    final uName = newRecord['user_name']?.toString() ?? '';
    final uAvatar = newRecord['avatar_url']?.toString() ?? '';
    final isMuted = newRecord['is_muted'] as bool? ?? false;
    final currentUserId = AuthSessionManager.currentUserId;

    setState(() {
      if (uid.isNotEmpty) {
        _seats[idx]['userId'] = uid;
        _seats[idx]['name'] = uName;
        _seats[idx]['avatar'] = uAvatar.isNotEmpty ? uAvatar : null;
        _seats[idx]['isMuted'] = isMuted;

        if (currentUserId != null && uid == currentUserId) {
          _mySeatIndex = idx;
          _isMicMuted = isMuted;
        }
      } else {
        _seats[idx]['userId'] = null;
        _seats[idx]['name'] = null;
        _seats[idx]['avatar'] = null;
        _seats[idx]['isMuted'] = false;
        _seats[idx]['isSpeaking'] = false;

        if (_mySeatIndex == idx) {
          _mySeatIndex = null;
          _isMicMuted = true;
        }
      }
    });
  }

  Future<void> _initLiveKit() async {
    setState(() => _isConnectingAudio = true);

    final currentUserId = AuthSessionManager.currentUserId ??
        'guest_${DateTime.now().millisecondsSinceEpoch}';
    final profile = context.read<ProfileBloc>().state.profile;
    final myName = profile.nickname.isNotEmpty ? profile.nickname : 'User';

    _audioService.onActiveSpeakersChanged = (speakers) {
      if (!mounted) return;
      setState(() {
        for (var seat in _seats) {
          final sUid = seat['userId']?.toString();
          final sName = seat['name']?.toString();
          if (seat['avatar'] != null && (sUid != null || sName != null)) {
            final isSpeaking = speakers.any((s) =>
                (sUid != null && s.identity == sUid) ||
                (sName != null && s.name == sName) ||
                (s.identity == currentUserId && seat['index'] == _mySeatIndex));
            seat['isSpeaking'] = isSpeaking && !(seat['isMuted'] as bool);
          } else {
            seat['isSpeaking'] = false;
          }
        }
      });
    };

    _audioService.onRoomDisconnected = () {
      if (!mounted) return;
      setState(() {
        _isAudioConnected = false;
        _isMicMuted = true;
        if (_mySeatIndex != null) {
          _seats[_mySeatIndex!]['isSpeaking'] = false;
        }
      });
    };

    final success = await _audioService.connect(
      roomId: 'room_${widget.room.id}',
      userId: currentUserId,
      userName: myName,
    );

    if (mounted) {
      setState(() {
        _isConnectingAudio = false;
        _isAudioConnected = success;
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _seatRequestTimer?.cancel();
    _audioService.disconnect();
    if (_roomChannel != null) {
      SupabaseConfig.client.removeChannel(_roomChannel!);
      _roomChannel = null;
    }
    _msgController.dispose();
    _giftBannerTimer?.cancel();
    _pkTimer?.cancel();
    super.dispose();
  }

  Future<void> _takeSeat(int index) async {
    final currentUserId = AuthSessionManager.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to take a mic seat!')),
      );
      return;
    }

    final profile = context.read<ProfileBloc>().state.profile;
    final myName = profile.nickname.isNotEmpty ? profile.nickname : 'User';
    final myAvatar = profile.avatarUrl.isNotEmpty
        ? profile.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

    // Request microphone permission & enable mic via LiveKit WebRTC
    final micSuccess = await _audioService.enableMicrophone();

    final prevSeatIndex = _mySeatIndex;

    if (mounted) {
      setState(() {
        // Clear previous seat if seated elsewhere
        if (prevSeatIndex != null && prevSeatIndex != index) {
          _seats[prevSeatIndex]['userId'] = null;
          _seats[prevSeatIndex]['avatar'] = null;
          _seats[prevSeatIndex]['name'] = null;
          _seats[prevSeatIndex]['isSpeaking'] = false;
          _seats[prevSeatIndex]['isMuted'] = false;
        }

        _mySeatIndex = index;
        _isMicMuted = !micSuccess;
        _seats[index]['userId'] = currentUserId;
        _seats[index]['avatar'] = myAvatar;
        _seats[index]['name'] = myName;
        _seats[index]['isSpeaking'] = micSuccess;
        _seats[index]['isMuted'] = !micSuccess;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(micSuccess ? Icons.mic : Icons.mic_off, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                micSuccess
                    ? 'Joined Mic Seat ${index + 1}! Live voice streaming 🎙️'
                    : 'Joined Mic Seat ${index + 1}! (Mic permission required)',
              ),
            ],
          ),
          backgroundColor: micSuccess ? AppColors.gemEmerald : Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      if (prevSeatIndex != null && prevSeatIndex != index) {
        // Clear old seat in Supabase
        await SupabaseConfig.client.from('room_seats').update({
          'user_id': null,
          'user_name': null,
          'avatar_url': null,
          'is_muted': false,
        }).match({'room_id': widget.room.id, 'seat_index': prevSeatIndex});
      }

      // Update seat in Supabase
      final updated = await SupabaseConfig.client.from('room_seats').update({
        'user_id': currentUserId,
        'user_name': myName,
        'avatar_url': myAvatar,
        'is_muted': !micSuccess,
      }).match({'room_id': widget.room.id, 'seat_index': index}).select();

      if (updated.isEmpty) {
        await SupabaseConfig.client.from('room_seats').insert({
          'room_id': widget.room.id,
          'seat_index': index,
          'user_id': currentUserId,
          'user_name': myName,
          'avatar_url': myAvatar,
          'is_muted': !micSuccess,
        });
      }
    } catch (e) {
      debugPrint('[LiveAudioRoom] Error updating seat in Supabase: $e');
    }
  }

  Future<void> _leaveSeat(int seatIndex) async {
    await _audioService.disableMicrophone();
    if (mounted) {
      setState(() {
        _mySeatIndex = null;
        _isMicMuted = true;
        _seats[seatIndex]['userId'] = null;
        _seats[seatIndex]['avatar'] = null;
        _seats[seatIndex]['name'] = null;
        _seats[seatIndex]['isSpeaking'] = false;
        _seats[seatIndex]['isMuted'] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You left the mic seat.'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    try {
      await SupabaseConfig.client.from('room_seats').update({
        'user_id': null,
        'user_name': null,
        'avatar_url': null,
        'is_muted': false,
      }).match({'room_id': widget.room.id, 'seat_index': seatIndex});
    } catch (e) {
      debugPrint('[LiveAudioRoom] Error clearing seat in Supabase: $e');
    }
  }

  Future<void> _toggleMic() async {
    if (_mySeatIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tap an empty seat to activate your microphone! 🎤'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final newMuted = !_isMicMuted;
    await _audioService.setMicrophoneMuted(newMuted);

    if (mounted) {
      setState(() {
        _isMicMuted = newMuted;
        _seats[_mySeatIndex!]['isMuted'] = newMuted;
        if (newMuted) {
          _seats[_mySeatIndex!]['isSpeaking'] = false;
        }
      });
    }

    try {
      await SupabaseConfig.client.from('room_seats').update({
        'is_muted': newMuted,
      }).match({'room_id': widget.room.id, 'seat_index': _mySeatIndex!});
    } catch (e) {
      debugPrint('[LiveAudioRoom] Error toggling seat mic in Supabase: $e');
    }
  }

  void _displayGiftBanner(String text) {
    setState(() => _activeGiftBanner = text);
    _giftBannerTimer?.cancel();
    _giftBannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeGiftBanner = null);
    });
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final profile = context.read<ProfileBloc>().state.profile;
    final myName = profile.nickname.isNotEmpty ? profile.nickname : 'Me';

    setState(() {
      _messages.add({'sender': myName, 'text': trimmed});
      _msgController.clear();
    });

    try {
      _roomChannel?.sendBroadcastMessage(
        event: 'chat',
        payload: {
          'sender': myName,
          'text': trimmed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('[LiveAudioRoom] Chat broadcast error: $e');
    }
  }

  void _triggerGift(String giftName, String icon, int cost) async {
    final currentUserId = AuthSessionManager.currentUserId;
    if (currentUserId == null) return;

    final profile = context.read<ProfileBloc>().state.profile;
    if (profile.coinBalance < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient coins! You need $cost coins. Top up in wallet. 🪙'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Top Up',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
              );
            },
          ),
        ),
      );
      return;
    }

    final senderName = profile.nickname.isNotEmpty ? profile.nickname : 'Me';
    _displayGiftBanner('✨ You gifted $icon $giftName to ${widget.room.hostName}! (+$cost Charm)');
    setState(() {
      _messages.add({
        'sender': '👑 $senderName',
        'text': 'sent $icon $giftName to Host',
      });
    });

    try {
      final newBalance = profile.coinBalance - cost;
      await SupabaseConfig.client
          .from('profiles')
          .update({'coin_balance': newBalance})
          .eq('id', currentUserId);

      // Record gift sent transaction
      final tx = WalletTransaction(
        id: 'GF-${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        type: 'gift_sent',
        title: 'Sent $icon $giftName to ${widget.room.hostName}',
        amount: cost.toDouble(),
        currency: 'coin',
        status: 'Completed',
        gateway: 'Voice Room Gift',
        createdAt: DateTime.now(),
      );
      await WalletTransactionService.recordTransaction(tx);

      // Credit host with earned gems in Supabase (70% charm converted to diamonds)
      if (_hostUserId.isNotEmpty && _hostUserId != currentUserId) {
        final hostRow = await SupabaseConfig.client
            .from('profiles')
            .select('gem_balance')
            .eq('id', _hostUserId)
            .maybeSingle();
        if (hostRow != null) {
          final hostGems = (hostRow['gem_balance'] as num?)?.toDouble() ?? 0.0;
          final earnedGems = (cost * 0.7);
          await SupabaseConfig.client
              .from('profiles')
              .update({'gem_balance': hostGems + earnedGems})
              .eq('id', _hostUserId);
        }
      }

      if (mounted) {
        context.read<ProfileBloc>().add(LoadUserProfileEvent());
      }

      _roomChannel?.sendBroadcastMessage(
        event: 'gift',
        payload: {
          'sender': senderName,
          'giftName': giftName,
          'giftIcon': icon,
          'cost': cost,
        },
      );
    } catch (e) {
      debugPrint('[LiveAudioRoom] Gift balance sync error: $e');
    }
  }

  void _showMySeatOptions(int seatIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF063025),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mic Seat ${seatIndex + 1} Settings',
              style: AppTextStyles.titleBold.copyWith(color: AppColors.goldCoin),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                _isMicMuted ? Icons.mic : Icons.mic_off,
                color: _isMicMuted ? AppColors.gemEmerald : Colors.redAccent,
              ),
              title: Text(
                _isMicMuted ? 'Unmute Live Microphone' : 'Mute Live Microphone',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleMic();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded, color: Colors.amber),
              title: const Text(
                'Leave Mic Seat',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _leaveSeat(seatIndex);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }


  void _promptSeatOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF07241C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic, color: AppColors.gemEmerald, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Join Mic Seat ${index + 1}',
                  style: AppTextStyles.titleBold.copyWith(color: AppColors.goldCoin),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Choose whether to request approval from Host or take seat directly:',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Request Seat from Host (হোস্টকে রিকোয়েস্ট পাঠান)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _sendSeatRequest(index);
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gemCyan,
                side: const BorderSide(color: AppColors.gemCyan, width: 1.2),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text(
                'Join Seat Directly (সরাসরি সিটে বসুন)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _takeSeat(index);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _sendSeatRequest(int index) {
    final currentUserId = AuthSessionManager.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to request a mic seat!')),
      );
      return;
    }

    final profile = context.read<ProfileBloc>().state.profile;
    final myName = profile.nickname.isNotEmpty ? profile.nickname : 'User';

    setState(() => _pendingSeatRequestIndex = index);
    _sendMessage('🙋 requested to join Mic Seat ${index + 1}');
    _displayGiftBanner('⏳ Seat ${index + 1} request sent to ${widget.room.hostName}!');

    _roomChannel?.sendBroadcastMessage(
      event: 'seat_request',
      payload: {
        'seatIndex': index,
        'userName': myName,
        'userId': currentUserId,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text('Mic Seat ${index + 1} request sent! Waiting for Host approval ⏳'),
          ],
        ),
        backgroundColor: const Color(0xFF0F382A),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulated host approval after 2.2 seconds for fluid localhost demonstration
    _seatRequestTimer?.cancel();
    _seatRequestTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted && _pendingSeatRequestIndex == index) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('🎉 ${widget.room.hostName} approved your Mic Seat ${index + 1} request!'),
              ],
            ),
            backgroundColor: AppColors.gemEmerald,
            duration: const Duration(seconds: 3),
          ),
        );
        _takeSeat(index);
        setState(() => _pendingSeatRequestIndex = null);
      }
    });
  }

  void _showLiveCoHostRequestModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF07241C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors_rounded, color: Color(0xFF00F5D4), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Live Stage & Co-Host Requests',
                  style: AppTextStyles.titleBold.copyWith(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Request ${widget.room.hostName} to join the live broadcast stage or PK battle:',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.white12),
              ),
              tileColor: Colors.black26,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF8B5CF6),
                child: Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
              ),
              title: const Text(
                'Request Video Co-Host (ভিডিও লাইভে ওঠার আবেদন)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Broadcast live camera stream alongside Host',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                _sendLiveCoHostRequest('Video Co-Host');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.white12),
              ),
              tileColor: Colors.black26,
              leading: const CircleAvatar(
                backgroundColor: AppColors.gemEmerald,
                child: Icon(Icons.mic_rounded, color: Colors.white, size: 20),
              ),
              title: const Text(
                'Request Audio Stage Co-Host (অডিও স্টেজে যোগ দিন)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Speak live with HD audio on stage',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                _sendLiveCoHostRequest('Audio Stage Co-Host');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.white12),
              ),
              tileColor: Colors.black26,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEF4444),
                child: Icon(Icons.sports_kabaddi_rounded, color: Colors.white, size: 20),
              ),
              title: const Text(
                'Challenge to 1v1 PK Duel (পিকে ব্যাটল চ্যালেঞ্জ)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: const Text(
                'Compete in live gift war duel with Host',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                _sendLiveCoHostRequest('1v1 PK Battle Challenge');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _sendLiveCoHostRequest(String type) {
    final profile = context.read<ProfileBloc>().state.profile;
    final myName = profile.nickname.isNotEmpty ? profile.nickname : 'User';

    _sendMessage('📡 sent a $type request to Host!');
    _displayGiftBanner('📡 $type request sent to ${widget.room.hostName}!');

    _roomChannel?.sendBroadcastMessage(
      event: 'live_request',
      payload: {
        'userName': myName,
        'type': type,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sensors_rounded, color: Color(0xFF00E5FF), size: 20),
            const SizedBox(width: 8),
            Text('$type request sent to ${widget.room.hostName}! Waiting for acceptance.'),
          ],
        ),
        backgroundColor: const Color(0xFF0F382A),
        duration: const Duration(seconds: 3),
      ),
    );

    // If video co-host, simulate approval and switch to video live stage after 2.5s
    if (type.contains('Video')) {
      Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _isVideoLiveMode = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('🎉 ${widget.room.hostName} approved your Video Co-Host request! Streaming live 📹'),
                ],
              ),
              backgroundColor: AppColors.gemEmerald,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    } else if (type.contains('Audio')) {
      Timer(const Duration(milliseconds: 2000), () {
        if (mounted) {
          // Take next empty guest seat (seats 1-7)
          int emptyIndex = 1;
          for (int i = 1; i < _seats.length; i++) {
            if (_seats[i]['avatar'] == null) {
              emptyIndex = i;
              break;
            }
          }
          _takeSeat(emptyIndex);
        }
      });
    }
  }

  void _showGameOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF07241C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gamepad_rounded, color: Color(0xFF8B5CF6), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Party Room Games & Challenges',
                  style: AppTextStyles.titleBold.copyWith(color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.white12),
              ),
              tileColor: Colors.black26,
              leading: const Text('🥣', style: TextStyle(fontSize: 26)),
              title: const Text('Bucket Prediction Game (8 Items)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Predict the winning item cycling from the magic bucket cauldron!', style: TextStyle(color: Colors.white60, fontSize: 11)),
              trailing: const Icon(Icons.play_circle_fill_rounded, color: AppColors.gemEmerald, size: 24),
              onTap: () {
                Navigator.pop(ctx);
                BucketPredictionGamePage.showGroupDrawer(
                  context,
                  roomId: widget.room.id,
                  roomName: widget.room.title,
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.white12),
              ),
              tileColor: Colors.black26,
              leading: const Text('🏎️', style: TextStyle(fontSize: 26)),
              title: const Text('Lucky Race Speed Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('High-speed racing game with live multiplayer odds', style: TextStyle(color: Colors.white60, fontSize: 11)),
              trailing: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFFF5252), size: 24),
              onTap: () {
                Navigator.pop(ctx);
                LuckyRaceGameDrawer.show(
                  context,
                  onRechargeTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.goldCoin),
              ),
              tileColor: AppColors.goldCoin.withValues(alpha: 0.12),
              leading: const Text('📢', style: TextStyle(fontSize: 26)),
              title: const Text('Invite Room to Play Game (গেমে রিকোয়েস্ট পাঠান)', style: TextStyle(color: AppColors.goldCoin, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Broadcast game invitation to everyone in the room', style: TextStyle(color: Colors.white70, fontSize: 11)),
              trailing: const Icon(Icons.send_rounded, color: AppColors.goldCoin, size: 20),
              onTap: () {
                Navigator.pop(ctx);
                _broadcastGameChallenge('Bucket Prediction Game');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _broadcastGameChallenge(String gameName) {
    final profile = context.read<ProfileBloc>().state.profile;
    final myName = profile.nickname.isNotEmpty ? profile.nickname : 'User';

    _sendMessage('🎮 challenged everyone to play $gameName! Tap Game icon to play together!');
    _displayGiftBanner('🎮 $myName invited everyone to $gameName!');

    _roomChannel?.sendBroadcastMessage(
      event: 'game_invite',
      payload: {
        'sender': myName,
        'game': gameName,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sports_esports_rounded, color: AppColors.goldCoin, size: 20),
            const SizedBox(width: 8),
            Text('Game challenge broadcasted to room! Starting $gameName...'),
          ],
        ),
        backgroundColor: const Color(0xFF0F382A),
        duration: const Duration(seconds: 2),
      ),
    );

    BucketPredictionGamePage.showGroupDrawer(
      context,
      roomId: widget.room.id,
      roomName: widget.room.title,
    );
  }

  Widget _buildLiveStage() {
    if (_isVideoLiveMode) {
      return _buildVideoLiveStage();
    }
    return _buildAudioLiveStage();
  }

  Widget _buildAudioLiveStage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gemEmerald.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gemEmerald.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [
                      AppColors.gemEmerald,
                      AppColors.goldCoin,
                      Colors.cyanAccent,
                      AppColors.gemEmerald,
                    ],
                    transform: GradientRotation(_pulseController.value * 6.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gemEmerald.withValues(alpha: 0.4 * _pulseController.value),
                      blurRadius: 8 * _pulseController.value,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CustomAvatar(
                  imageUrl: widget.room.hostAvatar,
                  radius: 20,
                  hasVipFrame: true,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.room.hostName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.goldCoin,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HOST',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent.withValues(
                              alpha: 0.5 + 0.5 * _pulseController.value,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'LIVE ON-AIR',
                      style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final val = _waveController.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildEqBar(8 + val * 10, AppColors.gemEmerald),
                            const SizedBox(width: 2),
                            _buildEqBar(5 + (1 - val) * 12, AppColors.gemCyan),
                            const SizedBox(width: 2),
                            _buildEqBar(12 + val * 8, AppColors.goldCoin),
                            const SizedBox(width: 2),
                            _buildEqBar(7 + (1 - val) * 12, AppColors.gemEmerald),
                            const SizedBox(width: 2),
                            _buildEqBar(10 + val * 6, AppColors.accentOrange),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _isVideoLiveMode = true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Watch Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLiveStage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF0F172A),
            Color(0xFF020617),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF60A5FA).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(
                            alpha: 0.4 + 0.6 * _pulseController.value,
                          ),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.3),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: CustomAvatar(
                        imageUrl: widget.room.hostAvatar,
                        radius: 34,
                        hasVipFrame: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.room.hostName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const RoyalBrandLogo(size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final val = _waveController.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEqBar(8 + val * 10, Colors.cyanAccent),
                        const SizedBox(width: 3),
                        _buildEqBar(12 + (1 - val) * 8, Colors.greenAccent),
                        const SizedBox(width: 3),
                        _buildEqBar(9 + val * 12, Colors.amberAccent),
                        const SizedBox(width: 3),
                        _buildEqBar(15 + (1 - val) * 6, Colors.pinkAccent),
                        const SizedBox(width: 3),
                        _buildEqBar(8 + val * 8, Colors.cyanAccent),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'LIVE 1080p',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: GestureDetector(
              onTap: () {
                setState(() => _isVideoLiveMode = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30, width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, color: Colors.white70, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Audio Mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqBar(double height, Color color) {
    return Container(
      width: 2.5,
      height: height.clamp(4.0, 22.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF072C22),
      body: Stack(
        children: [
          // Background atmospheric glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (_isPkBattleActive || widget.room.category == 'PK') _buildPkBattleBar(),
                _buildLiveStage(),
                const SizedBox(height: 4),
                _buildSeatsGrid(),
                if (_incomingSeatRequest != null && _isHost) _buildIncomingRequestBanner(),
                if (_isHost) _buildHostQuickToolsBar(),
                const Spacer(),
                if (_activeGiftBanner != null) _buildGiftBanner(),
                _buildChatArea(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPkBattleBar() {
    final mins = _pkSecondsLeft ~/ 60;
    final secs = _pkSecondsLeft % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF881337)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Blue team
          const Icon(Icons.shield, color: Color(0xFF60A5FA), size: 16),
          const SizedBox(width: 4),
          Text(
            'BLUE $_blueScore',
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          // Center PK Timer
          GestureDetector(
            onTap: _isHost ? _togglePkBattle : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '⚔️ PK ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Red team
          Text(
            '$_redScore RED',
            style: const TextStyle(
              color: Color(0xFFFCA5A5),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.shield, color: Color(0xFFF87171), size: 16),
        ],
      ),
    );
  }

  Widget _buildHostQuickToolsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D281E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. PK Duel Toggle
          _buildHostToolItem(
            icon: Icons.sports_mma_rounded,
            label: _isPkBattleActive ? 'End PK' : '⚔️ PK Duel',
            color: _isPkBattleActive ? Colors.redAccent : const Color(0xFFFF5252),
            onTap: _togglePkBattle,
          ),
          // 2. Start Game
          _buildHostToolItem(
            icon: Icons.sports_esports_rounded,
            label: '🎮 Play Game',
            color: const Color(0xFF8B5CF6),
            onTap: _showGameOptionsModal,
          ),
          // 3. Audio/Video Mode
          _buildHostToolItem(
            icon: Icons.videocam_rounded,
            label: _isVideoLiveMode ? '🎙️ Audio Live' : '📹 Video Live',
            color: const Color(0xFF06B6D4),
            onTap: () {
              setState(() => _isVideoLiveMode = !_isVideoLiveMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isVideoLiveMode
                      ? '📹 Camera Live Mode Active! Streaming audio + HD video feed.'
                      : '🎙️ Switched to Audio Party Room stage.'),
                  backgroundColor: const Color(0xFF0F382A),
                  duration: const Duration(seconds: 2),
                ),
              );
              _sendMessage(_isVideoLiveMode
                  ? '📹 Host switched stream to Live HD Video mode!'
                  : '🎙️ Host switched stream to Audio Room mode!');
            },
          ),
          // 4. Lock/Unlock Seats
          _buildHostToolItem(
            icon: Icons.lock_outline_rounded,
            label: '🔒 Seat Lock',
            color: AppColors.goldCoin,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔒 Seat Lock Active: Listeners must request Host permission to mic!'),
                  backgroundColor: Color(0xFF0F382A),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHostToolItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequestBanner() {
    final req = _incomingSeatRequest;
    if (req == null) return const SizedBox.shrink();

    final userName = req['user']?.toString() ?? 'Guest';
    final seatIdx = (req['seatIndex'] as num?)?.toInt() ?? 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.record_voice_over_rounded, color: AppColors.goldCoin, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🙋 $userName wants Mic Seat ${seatIdx + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Consent required to join live stage',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Approve Button
          InkWell(
            onTap: () => _approveSeatRequest(req),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gemEmerald,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Decline Button
          InkWell(
            onTap: () {
              setState(() => _incomingSeatRequest = null);
              _sendMessage('❌ Host declined mic seat request');
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _approveSeatRequest(Map<String, dynamic> req) {
    final seatIdx = (req['seatIndex'] as num?)?.toInt() ?? 1;
    final userName = req['user']?.toString() ?? 'Guest';
    final userId = req['userId']?.toString() ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final avatar = req['avatar']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

    setState(() {
      _incomingSeatRequest = null;
      if (seatIdx >= 0 && seatIdx < _seats.length) {
        _seats[seatIdx]['userId'] = userId;
        _seats[seatIdx]['name'] = userName;
        _seats[seatIdx]['avatar'] = avatar;
        _seats[seatIdx]['isSpeaking'] = true;
        _seats[seatIdx]['isMuted'] = false;
      }
    });

    _sendMessage('🎉 Host approved $userName onto Mic Seat ${seatIdx + 1}!');
    _displayGiftBanner('🎙️ $userName is now Live on Mic Seat ${seatIdx + 1}!');

    _roomChannel?.sendBroadcastMessage(
      event: 'seat_approved',
      payload: {
        'seatIndex': seatIdx,
        'userId': userId,
        'userName': userName,
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CustomAvatar(
            imageUrl: widget.room.hostAvatar,
            radius: 20,
            hasVipFrame: true,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.room.title,
                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const RoyalBrandLogo(size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'ID: ${widget.room.id}',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isAudioConnected
                            ? AppColors.gemEmerald.withValues(alpha: 0.25)
                            : (_isConnectingAudio
                                ? Colors.amber.withValues(alpha: 0.2)
                                : Colors.redAccent.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isAudioConnected
                              ? AppColors.gemEmerald
                              : (_isConnectingAudio ? Colors.amber : Colors.redAccent),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isAudioConnected
                                  ? AppColors.gemEmerald
                                  : (_isConnectingAudio ? Colors.amber : Colors.redAccent),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAudioConnected
                                ? 'WebRTC Live'
                                : (_isConnectingAudio ? 'Connecting...' : 'Offline'),
                            style: TextStyle(
                              color: _isAudioConnected
                                  ? AppColors.gemEmerald
                                  : (_isConnectingAudio ? Colors.amber : Colors.redAccent),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldCoin, Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldCoin.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '👑 Host',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () {
                if (!_isFollowing) {
                  setState(() => _isFollowing = true);
                  _sendMessage('❤️ followed Host ${widget.room.hostName}!');
                  _displayGiftBanner('❤️ You are now following ${widget.room.hostName}!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pinkAccent, size: 20),
                          const SizedBox(width: 8),
                          Text('You followed ${widget.room.hostName}! 💖'),
                        ],
                      ),
                      backgroundColor: AppColors.primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  setState(() => _isFollowing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You unfollowed ${widget.room.hostName}.'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isFollowing
                        ? const [AppColors.gemEmerald, Color(0xFF059669)]
                        : const [Color(0xFFFF7A00), Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isFollowing ? AppColors.gemEmerald : AppColors.accentOrange).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isFollowing ? Icons.check_circle_rounded : Icons.favorite_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isFollowing ? 'Following' : '+ Follow',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _seats.length,
        itemBuilder: (context, index) {
          final seat = _seats[index];
          final bool isOccupied = seat['avatar'] != null;
          final bool isSpeaking = seat['isSpeaking'] as bool;
          final bool isMuted = seat['isMuted'] as bool;

          return GestureDetector(
            onTap: () {
              final currentUserId = AuthSessionManager.currentUserId;
              final isMySeat = index == _mySeatIndex ||
                  (currentUserId != null && seat['userId'] != null && seat['userId'] == currentUserId);

              if (isMySeat) {
                _showMySeatOptions(index);
              } else if (isOccupied) {
                UserProfilePopover.show(
                  context,
                  username: seat['name'] ?? 'User',
                  avatarUrl: seat['avatar'] as String?,
                  countryFlag: '🇧🇩',
                  countryName: 'Bangladesh',
                  gender: index % 2 == 0 ? '♀' : '♂',
                  age: 19 + index,
                  wealthLevel: (seat['isHost'] as bool) ? 5 : 2,
                  charmLevel: (seat['isHost'] as bool) ? 6 : 3,
                  onSendGift: () {
                    Navigator.pop(context);
                    _showGiftModal();
                  },
                  onMention: () {
                    Navigator.pop(context);
                    setState(() {
                      _msgController.text = '@${seat['name']} ';
                    });
                  },
                  onChat: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversationPage(
                          chat: ChatItem(
                            id: 'chat_$index',
                            title: seat['name'] ?? 'User',
                            subtitle: 'Hey! Nice meeting you in ${widget.room.title}',
                            timestamp: 'Just now',
                            unreadCount: 0,
                            type: ChatType.direct,
                            avatarUrl: seat['avatar'] as String?,
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                if (_pendingSeatRequestIndex == index) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your seat request is pending host approval ⏳'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  _promptSeatOptions(index);
                }
              }
            },
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSpeaking)
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gemEmerald, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gemEmerald.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    isOccupied
                        ? CustomAvatar(
                            imageUrl: seat['avatar'] as String?,
                            radius: 24,
                            hasVipFrame: seat['isHost'] as bool,
                          )
                        : _pendingSeatRequestIndex == index
                            ? Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentOrange.withValues(alpha: 0.2),
                                  border: Border.all(color: AppColors.goldCoin, width: 2),
                                ),
                                child: const Icon(
                                  Icons.hourglass_top_rounded,
                                  color: AppColors.goldCoin,
                                  size: 22,
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                              ),
                    if (isOccupied && isMuted)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic_off,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    if (seat['isHost'] as bool)
                      Positioned(
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.goldCoin,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isOccupied
                      ? (seat['name'] ?? 'Guest')
                      : (_pendingSeatRequestIndex == index ? 'Pending...' : '${index + 1}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isOccupied ? Colors.white : Colors.white38,
                    fontWeight: isOccupied ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGiftBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB800), Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _activeGiftBanner!,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        reverse: true,
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final msg = _messages[_messages.length - 1 - index];
          final isSys = msg['sender'] == 'System';

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSys ? AppColors.primaryGreen.withValues(alpha: 0.4) : Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${msg['sender']}: ',
                      style: TextStyle(
                        color: isSys ? AppColors.goldCoin : AppColors.gemCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: msg['text'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          // Chat input field
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Say something...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (txt) => _sendMessage(txt),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Join Live / Co-Host Request button
          _buildCircleAction(
            icon: Icons.sensors_rounded,
            color: const Color(0xFF00F5D4),
            onTap: _showLiveCoHostRequestModal,
          ),
          const SizedBox(width: 6),

          // Mic toggle
          _buildCircleAction(
            icon: _isMicMuted ? Icons.mic_off : Icons.mic,
            color: _isMicMuted ? Colors.redAccent : AppColors.gemEmerald,
            onTap: _toggleMic,
          ),
          const SizedBox(width: 6),

          // Game and Challenge Hub
          _buildCircleAction(
            icon: Icons.gamepad_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: _showGameOptionsModal,
          ),
          const SizedBox(width: 6),

          // Gift Button (Golden box)
          _buildCircleAction(
            icon: Icons.card_giftcard_rounded,
            color: AppColors.goldCoin,
            onTap: _showGiftModal,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _showGiftModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GiftBottomSheet(onSendGift: _triggerGift),
    );
  }
}

class _GiftBottomSheet extends StatelessWidget {
  final Function(String name, String icon, int cost) onSendGift;

  const _GiftBottomSheet({required this.onSendGift});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      {'name': 'Royal Rose', 'cost': 10, 'icon': '🌹'},
      {'name': 'Emerald Gem', 'cost': 50, 'icon': '💎'},
      {'name': 'Imperial Crown', 'cost': 200, 'icon': '👑'},
      {'name': 'Golden Lion', 'cost': 500, 'icon': '🦁'},
      {'name': 'Royal Supercar', 'cost': 2000, 'icon': '🏎️'},
      {'name': 'Diamond Castle', 'cost': 5000, 'icon': '🏰'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0C4636),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Virtual Gift',
                style: AppTextStyles.titleBold.copyWith(color: AppColors.goldCoin),
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  final coins = profileState.profile.coinBalance;
                  final coinStr = coins >= 1000
                      ? '${(coins / 1000).toStringAsFixed(2)}K'
                      : coins.toInt().toString();
                  return Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        coinStr,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: gifts.length,
            itemBuilder: (context, i) {
              final g = gifts[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSendGift(g['name'] as String, g['icon'] as String, g['cost'] as int);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(g['icon'] as String, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        g['name'] as String,
                        style: AppTextStyles.caption.copyWith(color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            '${g['cost']}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.goldCoin,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
