import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/currency_badge.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';
import '../widgets/balloon_sky_game_view.dart';
import '../widgets/bucket_prediction_game_view.dart';
import '../widgets/color_prediction_game_view.dart';
import '../widgets/seven_up_game_view.dart';

class GamesTabPage extends StatefulWidget {
  const GamesTabPage({super.key});

  @override
  State<GamesTabPage> createState() => _GamesTabPageState();
}

class _GamesTabPageState extends State<GamesTabPage> {
  int _selectedGameIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Brand & Real Coin Balance Bar
              _buildTopBar(context),
              const SizedBox(height: 10),

              // 2. Game Selector Strip (1/4 Active + Ready for next 3 games)
              _buildGameSelectorBar(),
              const SizedBox(height: 12),

              // 3. Active Game View (1: Bucket Spin | 2: Color Spin | 3: 7 Up 7 Down | 4: Balloon Sky)
              if (_selectedGameIndex == 0)
                const BucketPredictionGameView()
              else if (_selectedGameIndex == 1)
                const ColorPredictionGameView()
              else if (_selectedGameIndex == 2)
                const SevenUpGameView()
              else
                const BalloonSkyGameView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const RoyalBrandLogo(size: 32, showText: true),
        const Spacer(),
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final coins = profileState.profile.coinBalance;
            final amountStr = coins >= 1000
                ? '${(coins / 1000).toStringAsFixed(2)}K'
                : coins.toInt().toString();
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                );
              },
              child: CurrencyBadge(amount: amountStr),
            );
          },
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LeaderboardPage(initialTabIndex: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldCoin.withValues(alpha: 0.45),
              ),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.goldCoin,
              size: 19,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameSelectorBar() {
    final slots = [
      {'icon': '🪣', 'title': '1. Bucket Spin', 'enabled': true},
      {'icon': '🎨', 'title': '2. Color Spin', 'enabled': true},
      {'icon': '🎲', 'title': '3. 7 Up 7 Down', 'enabled': true},
      {'icon': '🎈', 'title': '4. Balloon Sky', 'enabled': true},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(slots.length, (i) {
          final slot = slots[i];
          final enabled = slot['enabled'] as bool;
          final isSelected = _selectedGameIndex == i;

          return GestureDetector(
            onTap: () {
              if (enabled) {
                setState(() => _selectedGameIndex = i);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${slot['title']} coming soon!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.white.withValues(alpha: enabled ? 0.09 : 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : enabled
                          ? AppColors.goldCoin.withValues(alpha: 0.4)
                          : Colors.white12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(slot['icon'] as String, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    slot['title'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : enabled
                              ? Colors.white
                              : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
