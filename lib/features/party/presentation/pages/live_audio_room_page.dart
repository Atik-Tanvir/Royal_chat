import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/entities/party_room.dart';
import '../widgets/lucky_race_game_drawer.dart';
import '../widgets/user_profile_popover.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';
import '../../../chat/presentation/pages/conversation_page.dart';
import '../../../chat/domain/entities/chat_item.dart';

class LiveAudioRoomPage extends StatefulWidget {
  final PartyRoom room;

  const LiveAudioRoomPage({super.key, required this.room});

  @override
  State<LiveAudioRoomPage> createState() => _LiveAudioRoomPageState();
}

class _LiveAudioRoomPageState extends State<LiveAudioRoomPage> {
  bool _isMicMuted = false;
  bool _isFollowing = false;
  String? _activeGiftBanner;
  Timer? _giftBannerTimer;

  // 8 seats: Index 0 is Host, Indices 1-7 are Guests
  late List<Map<String, dynamic>> _seats;

  final List<Map<String, String>> _messages = [
    {'sender': 'System', 'text': 'Welcome to the party room! Keep it friendly and fun.'},
    {'sender': 'User31823345', 'text': 'Hello everyone! 🌷'},
    {'sender': 'yanboyy', 'text': 'Nice vibe here! 🎶'},
  ];

  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seats = [
      {
        'index': 0,
        'name': widget.room.hostName,
        'avatar': widget.room.hostAvatar,
        'isHost': true,
        'isMuted': false,
        'isSpeaking': true,
      },
      {
        'index': 1,
        'name': 'Alex',
        'avatar': widget.room.seatedAvatars.isNotEmpty ? widget.room.seatedAvatars[0] : null,
        'isHost': false,
        'isMuted': false,
        'isSpeaking': false,
      },
      {
        'index': 2,
        'name': 'Sara',
        'avatar': widget.room.seatedAvatars.length > 1 ? widget.room.seatedAvatars[1] : null,
        'isHost': false,
        'isMuted': true,
        'isSpeaking': false,
      },
      {'index': 3, 'name': null, 'avatar': null, 'isHost': false, 'isMuted': false, 'isSpeaking': false},
      {'index': 4, 'name': null, 'avatar': null, 'isHost': false, 'isMuted': false, 'isSpeaking': false},
      {'index': 5, 'name': null, 'avatar': null, 'isHost': false, 'isMuted': false, 'isSpeaking': false},
      {'index': 6, 'name': null, 'avatar': null, 'isHost': false, 'isMuted': false, 'isSpeaking': false},
      {'index': 7, 'name': null, 'avatar': null, 'isHost': false, 'isMuted': false, 'isSpeaking': false},
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _giftBannerTimer?.cancel();
    super.dispose();
  }

  void _triggerGift(String giftName, String icon) {
    setState(() {
      _activeGiftBanner = 'You sent $giftName to ${widget.room.hostName} $icon';
    });
    _giftBannerTimer?.cancel();
    _giftBannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _activeGiftBanner = null);
    });
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
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildPkBattleBar(),
                const SizedBox(height: 8),
                _buildSeatsGrid(),
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
          const Text(
            'BLUE 450',
            style: TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          // Center PK Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PK ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '04:30',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Red team
          const Text(
            '720 RED',
            style: TextStyle(
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
                Text(
                  widget.room.title,
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${widget.room.id} • ${widget.room.category}',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isFollowing = !_isFollowing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isFollowing ? Colors.white24 : AppColors.accentOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _isFollowing ? 'Joined' : '+ Follow',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
              if (isOccupied) {
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
                setState(() {
                  seat['avatar'] = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb';
                  seat['name'] = 'Me';
                  seat['isSpeaking'] = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You joined Mic Seat ${index + 1}! 🎤'),
                    backgroundColor: AppColors.gemEmerald,
                    duration: const Duration(seconds: 2),
                  ),
                );
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
                  isOccupied ? (seat['name'] ?? 'Guest') : '${index + 1}',
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
            color: AppColors.accentOrange.withOpacity(0.5),
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
                color: isSys ? AppColors.primaryGreen.withOpacity(0.4) : Colors.black38,
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
        color: Colors.black.withOpacity(0.4),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          // Chat input field
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
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
                      onSubmitted: (txt) {
                        if (txt.trim().isNotEmpty) {
                          setState(() {
                            _messages.add({'sender': 'Me', 'text': txt.trim()});
                            _msgController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Mic toggle
          _buildCircleAction(
            icon: _isMicMuted ? Icons.mic_off : Icons.mic,
            color: _isMicMuted ? Colors.redAccent : AppColors.gemEmerald,
            onTap: () => setState(() => _isMicMuted = !_isMicMuted),
          ),
          // Lucky Race Mini-game trigger
          _buildCircleAction(
            icon: Icons.sports_score_rounded,
            color: const Color(0xFFFF5252),
            onTap: () {
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
          const SizedBox(width: 10),

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
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
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
  final Function(String name, String icon) onSendGift;

  const _GiftBottomSheet({required this.onSendGift});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      {'name': 'Rose', 'cost': 10, 'icon': '🌹'},
      {'name': 'Kiss', 'cost': 50, 'icon': '💋'},
      {'name': 'Cat Paw', 'cost': 100, 'icon': '🐾'},
      {'name': 'Crown', 'cost': 500, 'icon': '👑'},
      {'name': 'Sports Car', 'cost': 2000, 'icon': '🏎️'},
      {'name': 'Rocket', 'cost': 5000, 'icon': '🚀'},
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
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '158.98K',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                  onSendGift(g['name'] as String, g['icon'] as String);
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
