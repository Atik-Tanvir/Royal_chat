import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SingleChatHost {
  final String id;
  final String name;
  final String avatarUrl;
  final int level;
  final bool isOnline;
  final String countryFlag;
  final String country;

  const SingleChatHost({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.level = 1,
    this.isOnline = true,
    this.countryFlag = '🇧🇩',
    this.country = 'Bangladesh',
  });
}

class SingleChatCard extends StatelessWidget {
  final SingleChatHost host;
  final VoidCallback onTap;
  final VoidCallback onCallTap;

  const SingleChatCard({
    super.key,
    required this.host,
    required this.onTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF0F3A2E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full Portrait Background Image
            CachedNetworkImage(
              imageUrl: host.avatarUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF0D3227),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF0D3227),
                child: const Icon(
                  Icons.person,
                  color: Colors.white38,
                  size: 48,
                ),
              ),
            ),

            // Gradient Overlay at bottom for text contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.45, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Bottom-Left: Name + Online Dot + Level Badge
            Positioned(
              left: 10,
              bottom: 10,
              right: 56, // Leave room for Call Button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    host.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Online / Live Status Dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: host.isOnline
                              ? const Color(0xFFEF4444) // Red live dot like screenshot
                              : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (host.isOnline ? Colors.redAccent : Colors.grey)
                                  .withValues(alpha: 0.6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),

                      // Level Badge Pill (e.g. LV3, LV4)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shield_rounded,
                              size: 9,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'LV${host.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
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

            // Bottom-Right: Cyan / Teal Phone Call Button
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: onCallTap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B0FF).withValues(alpha: 0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<SingleChatHost> dummySingleChatHosts = [
  SingleChatHost(
    id: 'host_1',
    name: 'Tania Ahmed',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&fit=crop&q=80',
    level: 3,
    isOnline: true,
  ),
  SingleChatHost(
    id: 'host_2',
    name: 'Nusrat Jahan',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&fit=crop&q=80',
    level: 4,
    isOnline: true,
  ),
  SingleChatHost(
    id: 'host_3',
    name: 'Sadia Islam',
    avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&fit=crop&q=80',
    level: 5,
    isOnline: true,
  ),
  SingleChatHost(
    id: 'host_4',
    name: 'Ayesha Rahman',
    avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&fit=crop&q=80',
    level: 2,
    isOnline: true,
  ),
  SingleChatHost(
    id: 'host_5',
    name: 'Rimi Chowdhury',
    avatarUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=600&fit=crop&q=80',
    level: 6,
    isOnline: false,
  ),
  SingleChatHost(
    id: 'host_6',
    name: 'Farzana Mimi',
    avatarUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=600&fit=crop&q=80',
    level: 3,
    isOnline: true,
  ),
  SingleChatHost(
    id: 'host_7',
    name: 'Mehvish Khan',
    avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&fit=crop&q=80',
    level: 4,
    isOnline: true,
  ),
  SingleChatHost(
    id: 'host_8',
    name: 'Priya Sen',
    avatarUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=600&fit=crop&q=80',
    level: 5,
    isOnline: true,
  ),
];

