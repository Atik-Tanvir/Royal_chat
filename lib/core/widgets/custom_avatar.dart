import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool hasVipFrame;
  final bool isLive;
  final String? countryFlag;
  final Widget? fallbackIcon;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.hasVipFrame = false,
    this.isLive = false,
    this.countryFlag,
    this.fallbackIcon,
  });

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
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.bgMidGreen,
                      child: const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildFallback(),
                  )
                : _buildFallback(),
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

  Widget _buildFallback() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: const Color(0xFFD8F3DC),
      child: Center(
        child: fallbackIcon ??
            const Icon(
              Icons.pets,
              color: AppColors.primaryGreen,
              size: 20,
            ),
      ),
    );
  }
}
