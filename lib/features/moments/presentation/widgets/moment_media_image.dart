import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Shared media renderer for Moments posts, reels, and Stories.
/// Supports `data:image` base64 uploads, rich illustrated `royal_art://` cards,
/// and network images with safe fallbacks so broken/black squares never appear.
class MomentMediaImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MomentMediaImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static Uint8List? decodeDataUri(String uri) {
    try {
      final comma = uri.indexOf(',');
      if (comma == -1) return null;
      return base64Decode(uri.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (source.startsWith('data:image')) {
      final bytes = decodeDataUri(source);
      if (bytes != null && bytes.isNotEmpty) {
        child = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallbackArtwork('media'),
        );
      } else {
        child = _buildFallbackArtwork('media');
      }
    } else if (source.startsWith('royal_art://')) {
      final key = source.replaceFirst('royal_art://', '');
      child = _buildRoyalArtwork(key);
    } else if (source.trim().isEmpty) {
      child = _buildFallbackArtwork('media');
    } else {
      child = Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, childWidget, loadingProgress) {
          if (loadingProgress == null) return childWidget;
          return Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9F5EC), Color(0xFFD4ECDC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFF1F7A52),
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildFallbackArtwork(source),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }

  Widget _buildRoyalArtwork(String key) {
    final spec = _artSpecs[key] ?? _defaultSpec;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: spec.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -22,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(spec.icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  spec.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    spec.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackArtwork(String hint) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F7A52), Color(0xFF0E4D36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_rounded,
              color: Colors.white.withOpacity(0.85),
              size: 34,
            ),
            const SizedBox(height: 6),
            Text(
              'Moment Snap',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _RoyalArtSpec _defaultSpec = _RoyalArtSpec(
    title: 'Gamegala Moment',
    subtitle: 'Community Highlight',
    icon: Icons.auto_awesome_rounded,
    colors: [Color(0xFF1B8A5A), Color(0xFF0F4C3A)],
  );

  static const Map<String, _RoyalArtSpec> _artSpecs = {
    'lucky_wheel': _RoyalArtSpec(
      title: '250,000 Coins!',
      subtitle: 'Lucky Wheel Jackpot',
      icon: Icons.casino_rounded,
      colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
    ),
    'party_stage': _RoyalArtSpec(
      title: 'Live Voice Party',
      subtitle: 'Golden Mic Night',
      icon: Icons.mic_rounded,
      colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
    ),
    'dhaka_skyline': _RoyalArtSpec(
      title: 'Evening Chai Vibes',
      subtitle: 'Dhaka Sunset',
      icon: Icons.local_cafe_rounded,
      colors: [Color(0xFF00897B), Color(0xFF004D40)],
    ),
    'pk_trophy': _RoyalArtSpec(
      title: 'PK Arena Crown',
      subtitle: 'Top Champion',
      icon: Icons.emoji_events_rounded,
      colors: [Color(0xFFC2185B), Color(0xFF880E4F)],
    ),
    'balloon_sky': _RoyalArtSpec(
      title: 'Balloon Sky Record',
      subtitle: 'High Altitude Run',
      icon: Icons.airplanemode_active_rounded,
      colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
    ),
  };
}

class _RoyalArtSpec {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _RoyalArtSpec({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
