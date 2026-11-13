import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable circular avatar supporting network URLs, `data:image` base64 URIs,
/// and deterministic `royal_avatar://<initials>:<hex>` monogram avatars.
class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool hasVipFrame;
  final bool isLive;
  final String? countryFlag;
  final Widget? fallbackIcon;
  final String? fallbackName;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.hasVipFrame = false,
    this.isLive = false,
    this.countryFlag,
    this.fallbackIcon,
    this.fallbackName,
  });

  static Uint8List? tryDecodeDataUri(String uri) {
    try {
      final commaIdx = uri.indexOf(',');
      if (commaIdx == -1) return null;
      return base64Decode(uri.substring(commaIdx + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Live audio pulse glow
        if (isLive)
          Container(
            width: diameter + 10,
            height: diameter + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentOrange,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

        // VIP Golden Frame Border
        Container(
          width: diameter + (hasVipFrame ? 6 : 0),
          height: diameter + (hasVipFrame ? 6 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasVipFrame
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFFDF00),
                      Color(0xFFD4AF37),
                      Color(0xFFFFF8DC),
                      Color(0xFFAA771C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: hasVipFrame
                ? null
                : Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          padding: EdgeInsets.all(hasVipFrame ? 2.5 : 0),
          child: ClipOval(
            child: _buildAvatarContent(diameter),
          ),
        ),

        // Country flag badge at bottom right
        if (countryFlag != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Text(
                countryFlag!,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent(double diameter) {
    final src = imageUrl?.trim() ?? '';
    if (src.isEmpty) {
      return _buildFallback();
    }

    if (src.startsWith('data:image')) {
      final bytes = tryDecodeDataUri(src);
      if (bytes != null && bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
      return _buildFallback();
    }

    if (src.startsWith('royal_avatar://')) {
      return _buildRoyalMonogram(src, diameter);
    }

    return Image.network(
      src,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: diameter,
          height: diameter,
          color: AppColors.bgMidGreen,
          child: const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildRoyalMonogram(String uri, double diameter) {
    final raw = uri.replaceFirst('royal_avatar://', '');
    final parts = raw.split(':');
    final initials = (parts.isNotEmpty && parts[0].isNotEmpty)
        ? parts[0].toUpperCase()
        : _deriveInitials(fallbackName);
    Color baseColor = const Color(0xFF1F7A52);
    if (parts.length > 1) {
      final parsed = int.tryParse(parts[1].replaceAll('#', ''), radix: 16);
      if (parsed != null) {
        baseColor = Color(0xFF000000 | parsed);
      }
    }
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.28) ?? baseColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: (radius * 0.72).clamp(11.0, 26.0),
          ),
        ),
      ),
    );
  }

  String _deriveInitials(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return 'G';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildFallback() {
    final trimmedName = fallbackName?.trim() ?? '';
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD8F3DC), Color(0xFFB7E4C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: fallbackIcon ??
            (trimmedName.isNotEmpty
                ? Text(
                    _deriveInitials(trimmedName),
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: (radius * 0.7).clamp(11.0, 24.0),
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryGreen,
                    size: (radius * 0.9).clamp(16.0, 34.0),
                  )),
      ),
    );
  }
}
