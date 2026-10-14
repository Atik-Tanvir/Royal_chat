import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum CurrencyType { coin, gem }

class CurrencyBadge extends StatelessWidget {
  final String amount;
  final CurrencyType type;
  final VoidCallback? onTap;

  const CurrencyBadge({
    super.key,
    required this.amount,
    this.type = CurrencyType.coin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCoin = type == CurrencyType.coin;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCoin
                ? AppColors.goldCoin.withOpacity(0.6)
                : AppColors.gemEmerald.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isCoin
                      ? [AppColors.goldCoin, AppColors.goldCoinDark]
                      : [AppColors.gemCyan, AppColors.gemEmerald],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCoin ? AppColors.goldCoin : AppColors.gemEmerald)
                        .withOpacity(0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isCoin ? Icons.monetization_on : Icons.diamond,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              amount,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
