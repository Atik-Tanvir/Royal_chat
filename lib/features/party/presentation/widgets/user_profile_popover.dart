import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';

class UserProfilePopover extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final String countryFlag;
  final String countryName;
  final String gender;
  final int age;
  final int wealthLevel;
  final int charmLevel;
  final VoidCallback onSendGift;
  final VoidCallback onMention;
  final VoidCallback onChat;

  const UserProfilePopover({
    super.key,
    required this.username,
    this.avatarUrl,
    this.countryFlag = '🇧🇩',
    this.countryName = 'Bangladesh',
    this.gender = '♀',
    this.age = 19,
    this.wealthLevel = 3,
    this.charmLevel = 5,
    required this.onSendGift,
    required this.onMention,
    required this.onChat,
  });

  static void show(
    BuildContext context, {
    required String username,
    String? avatarUrl,
    String countryFlag = '🇧🇩',
    String countryName = 'Bangladesh',
    String gender = '♀',
    int age = 19,
    int wealthLevel = 3,
    int charmLevel = 5,
    required VoidCallback onSendGift,
    required VoidCallback onMention,
    required VoidCallback onChat,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfilePopover(
        username: username,
        avatarUrl: avatarUrl,
        countryFlag: countryFlag,
        countryName: countryName,
        gender: gender,
        age: age,
        wealthLevel: wealthLevel,
        charmLevel: charmLevel,
        onSendGift: onSendGift,
        onMention: onMention,
        onChat: onChat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Bar: Report Icon + Follow Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFF94A3B8), size: 24),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted to moderation team.')),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Followed $username!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.gemEmerald,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          // Avatar with VIP Frame
          CustomAvatar(
            imageUrl: avatarUrl,
            radius: 36,
            hasVipFrame: true,
          ),
          const SizedBox(height: 8),

          // Username
          Text(
            username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),

          // Badges: Country, Gender/Age, Wealth, Charm
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(countryFlag, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(countryName, style: const TextStyle(color: Color(0xFF475569), fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: gender == '♀' ? const Color(0xFFFF2A6D) : const Color(0xFF0072FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$gender $age',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0097A7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '💎 LV$wealthLevel',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '👑 LV$charmLevel',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gallery Thumbnails Row (Screenshot 19)
          SizedBox(
            height: 72,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildGalleryThumbnail(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                  isVideo: true,
                ),
                const SizedBox(width: 8),
                _buildGalleryThumbnail(
                  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
                  isVideo: true,
                ),
                const SizedBox(width: 8),
                _buildGalleryThumbnail(
                  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
                ),
                const SizedBox(width: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons: Chat | Send Gift | Video Call
          Row(
            children: [
              // Chat (Yellow circle/pill)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onChat();
                },
                child: Container(
                  width: 52,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),

              // Send Gift (Pink gradient)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onSendGift();
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2A6D), Color(0xFFFF5252)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Send Gift',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Video Call (Green gradient)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connecting video call to $username...')),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Video Call',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // "@ Her" mention link
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onMention();
            },
            child: Text(
              '@ ${gender == '♀' ? 'Her' : 'Him'}',
              style: const TextStyle(
                color: AppColors.gemEmerald,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryThumbnail(String url, {bool isVideo = false}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: isVideo
          ? Container(
              color: Colors.black26,
              child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 26),
            )
          : null,
    );
  }
}
