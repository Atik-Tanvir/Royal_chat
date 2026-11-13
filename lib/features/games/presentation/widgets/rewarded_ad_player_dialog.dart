import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';
import '../../domain/entities/rewarded_ad_item.dart';

/// Interactive Ad Player modal displaying the active Rewarded Ad(s)
/// configured from the Admin Web Panel (`/ads`).
class RewardedAdPlayerDialog extends StatefulWidget {
  final RewardedAdsConfig config;
  final void Function(RewardedAdItem ad) onClaimReward;

  const RewardedAdPlayerDialog({
    super.key,
    required this.config,
    required this.onClaimReward,
  });

  @override
  State<RewardedAdPlayerDialog> createState() => _RewardedAdPlayerDialogState();
}

class _RewardedAdPlayerDialogState extends State<RewardedAdPlayerDialog> {
  int _selectedAdIndex = 0;
  int _secondsRemaining = 0;
  int _totalDuration = 5;
  bool _isCompleted = false;
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    if (widget.config.adsEnabled && widget.config.activeAds.isNotEmpty) {
      _startPlayingAd(0);
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  void _startPlayingAd(int index) {
    _adTimer?.cancel();
    final ad = widget.config.activeAds[index];
    setState(() {
      _selectedAdIndex = index;
      _totalDuration = ad.durationSeconds > 0 ? ad.durationSeconds : 5;
      _secondsRemaining = _totalDuration;
      _isCompleted = false;
    });

    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isCompleted = true;
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeAds = widget.config.activeAds;
    final hasAds = widget.config.adsEnabled && activeAds.isNotEmpty;

    return Dialog(
      backgroundColor: const Color(0xFF100724),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.goldCoin, width: 1.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: !hasAds
            ? _buildAdsDisabledView(context)
            : _buildActiveAdPlayer(context, activeAds),
      ),
    );
  }

  Widget _buildAdsDisabledView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.tv_off_rounded, color: Colors.white54, size: 48),
        const SizedBox(height: 12),
        const Text(
          'No Active Ads Available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rewarded video ads are currently paused by the Admin. Please recharge coins in your wallet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.4),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white60)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldCoin,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                  );
                },
                child: const Text(
                  'Recharge',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveAdPlayer(
    BuildContext context,
    List<RewardedAdItem> activeAds,
  ) {
    final ad = activeAds[_selectedAdIndex];
    final progress = _totalDuration > 0
        ? (_totalDuration - _secondsRemaining) / _totalDuration
        : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.goldCoin.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.goldCoin),
              ),
              child: Text(
                'AD • ${ad.network}',
                style: const TextStyle(
                  color: AppColors.goldCoin,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _isCompleted ? 'Reward Ready!' : 'Wait ${_secondsRemaining}s',
                style: TextStyle(
                  color: _isCompleted ? Colors.black : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Multiple Admin-enabled ads selector if more than 1 active
        if (activeAds.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(activeAds.length, (i) {
                final item = activeAds[i];
                final isSelected = i == _selectedAdIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => _startPlayingAd(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.goldCoin
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.network} (+${item.rewardCoins})',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Simulated Video / Visual Ad Container
        Container(
          height: 156,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
            border: Border.all(color: Colors.white12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (ad.imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: ad.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: const Color(0xFF1F113B)),
                  )
                else
                  Container(color: const Color(0xFF1F113B)),

                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.play_circle_fill_rounded,
                        color: _isCompleted
                            ? const Color(0xFF34D399)
                            : AppColors.goldCoin,
                        size: 50,
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          ad.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              _isCompleted ? const Color(0xFF34D399) : AppColors.goldCoin,
            ),
          ),
        ),
        const SizedBox(height: 10),

        Text(
          ad.description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Bottom Buttons
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isCompleted
                    ? () {
                        Navigator.pop(context);
                        widget.onClaimReward(ad);
                      }
                    : null,
                icon: const Icon(Icons.monetization_on_rounded, size: 18),
                label: Text(
                  _isCompleted
                      ? 'Claim +${ad.rewardCoins} Coins'
                      : 'Watching Ad (${_secondsRemaining}s)...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.white12,
                  foregroundColor: _isCompleted ? Colors.black : Colors.white54,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
