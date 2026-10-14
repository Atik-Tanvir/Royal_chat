import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

enum WalletCardType { gem, coin }

class WalletCardWidget extends StatelessWidget {
  final WalletCardType type;
  final String amount;
  final VoidCallback onTap;

  const WalletCardWidget({
    super.key,
    required this.type,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGem = type == WalletCardType.gem;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isGem
                  ? [const Color(0xFF0D8F6C), const Color(0xFF075A43)]
                  : [const Color(0xFFE5A93B), const Color(0xFFB87818)],
            ),
            border: Border.all(
              color: isGem ? AppColors.gemEmerald : AppColors.borderGold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isGem ? AppColors.gemEmerald : AppColors.goldCoin).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ornate top crown crest
              Positioned(
                top: -1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: isGem ? const Color(0xFF0D8F6C) : const Color(0xFFE5A93B),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    border: Border.all(
                      color: isGem ? AppColors.gemEmerald : AppColors.borderGold,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isGem ? Icons.diamond_rounded : Icons.star_rounded,
                    size: 14,
                    color: isGem ? AppColors.gemCyan : AppColors.goldCoin,
                  ),
                ),
              ),

              // Content: Icon and Amount
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Gem or Coin Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isGem
                          ? const Icon(
                              Icons.diamond,
                              color: AppColors.gemCyan,
                              size: 32,
                            )
                          : Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                                ),
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Color(0xFFB87818),
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amount,
                    style: AppTextStyles.goldAmount.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        const Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
