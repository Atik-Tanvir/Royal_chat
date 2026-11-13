import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';

/// Shared Header, Stats Bar (Balance + Free Coins Ad Button + Pool), and Mode/History Strip
/// reused cleanly across Game #1 and Game #2.
class GameHeaderBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isGroupMode;
  final int timeLeft;
  final ValueChanged<bool> onModeChanged;
  final String? customTimerText;
  final bool? isUrgentOverride;
  final Color accentColor;

  const GameHeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isGroupMode,
    required this.timeLeft,
    required this.onModeChanged,
    this.customTimerText,
    this.isUrgentOverride,
    this.accentColor = AppColors.goldCoin,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = isUrgentOverride ?? (timeLeft <= 5 && timeLeft > 0);
    final secStr = timeLeft.toString().padLeft(2, '0');
    final displayTimer = customTimerText ?? '00:$secStr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        border: Border(
          bottom: BorderSide(color: accentColor.withValues(alpha: 0.35)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModePill(
                  label: 'Solo',
                  icon: Icons.person_rounded,
                  isActive: !isGroupMode,
                  onTap: () => onModeChanged(false),
                ),
                _buildModePill(
                  label: 'Group',
                  icon: Icons.groups_rounded,
                  isActive: isGroupMode,
                  onTap: () => onModeChanged(true),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFFFF4757),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4757)
                      .withValues(alpha: isUrgent ? 0.85 : 0.45),
                  blurRadius: isUrgent ? 12 : 6,
                ),
              ],
            ),
            child: Text(
              displayTimer,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.goldCoin : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? Colors.black : Colors.white70),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameStatsBar extends StatelessWidget {
  final double balance;
  final int totalPoolCount;
  final bool isLoadingAds;
  final VoidCallback onWatchAdTap;
  final String statsLabel;
  final bool showRightCoinIcon;

  const GameStatsBar({
    super.key,
    required this.balance,
    required this.totalPoolCount,
    required this.isLoadingAds,
    required this.onWatchAdTap,
    this.statsLabel = 'Pool: ',
    this.showRightCoinIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLowBalance = balance < 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      color: Colors.white.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                  );
                },
                child: Row(
                  children: [
                    const Text(
                      'Balance: ',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    Text(
                      '${balance.toInt()} 🪙',
                      style: TextStyle(
                        color: isLowBalance ? Colors.redAccent : AppColors.goldCoin,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onWatchAdTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLowBalance
                        ? const Color(0xFF10B981)
                        : AppColors.goldCoin.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLowBalance ? Colors.white : AppColors.goldCoin,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 12,
                        color: isLowBalance ? Colors.black : AppColors.goldCoin,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isLoadingAds ? 'Loading...' : 'Free Coins',
                        style: TextStyle(
                          color: isLowBalance ? Colors.black : AppColors.goldCoin,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                statsLabel,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                showRightCoinIcon ? '$totalPoolCount 🪙' : '$totalPoolCount',
                style: const TextStyle(
                  color: AppColors.goldCoin,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameModeAndHistoryStrip extends StatelessWidget {
  final bool isGroupMode;
  final bool isPartyLockedRoom;
  final String groupRoomName;
  final int roundNumber;
  final List<Widget> historyBadges;
  final VoidCallback? onGroupTableTap;

  const GameModeAndHistoryStrip({
    super.key,
    required this.isGroupMode,
    required this.isPartyLockedRoom,
    required this.groupRoomName,
    required this.roundNumber,
    required this.historyBadges,
    this.onGroupTableTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          if (isGroupMode)
            GestureDetector(
              onTap: isPartyLockedRoom ? null : onGroupTableTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D28D9).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.groups_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      groupRoomName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isPartyLockedRoom) ...[
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down,
                          color: Colors.white70, size: 14),
                    ],
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gemEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gemEmerald.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '👤 Solo • Round #$roundNumber',
                style: const TextStyle(
                  color: AppColors.gemEmerald,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Text(
            'History:',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: historyBadges),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared Admin freeze/disabled banner rendered cleanly above any paused game board.
class GameFrozenBanner extends StatelessWidget {
  final String message;

  const GameFrozenBanner({
    super.key,
    this.message = '⛔ This game is temporarily paused by Admin.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pause_circle_filled_rounded,
              color: Colors.redAccent, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
