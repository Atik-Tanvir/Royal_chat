import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class SignInRewardDialog extends StatefulWidget {
  final VoidCallback? onClaimed;

  const SignInRewardDialog({super.key, this.onClaimed});

  static void show(BuildContext context, {VoidCallback? onClaimed}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SignInRewardDialog(onClaimed: onClaimed),
    );
  }

  @override
  State<SignInRewardDialog> createState() => _SignInRewardDialogState();
}

class _SignInRewardDialogState extends State<SignInRewardDialog> {
  int _signedDays = 1;
  bool _claimedToday = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _days = [
    {'day': 'Day 1', 'coins': 2000.0, 'isSpecial': false},
    {'day': 'Day 2', 'coins': 2500.0, 'isSpecial': false},
    {'day': 'Day 3', 'coins': 3000.0, 'isSpecial': false},
    {'day': 'Day 4', 'coins': 3500.0, 'isSpecial': false},
    {'day': 'Day 5', 'coins': 4000.0, 'isSpecial': false},
    {'day': 'Day 6', 'coins': 4500.0, 'isSpecial': false},
    {'day': 'Day 7+', 'coins': 5000.0, 'isSpecial': true},
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final days = prefs.getInt('royal_signin_days') ?? 0;
      final lastDate = prefs.getString('royal_signin_last_date') ?? '';
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      if (mounted) {
        setState(() {
          _signedDays = days == 0 ? 1 : days;
          _claimedToday = (lastDate == todayStr);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claimReward() async {
    if (_claimedToday || _isLoading) return;

    final targetIndex = (_signedDays - 1).clamp(0, _days.length - 1);
    final rewardCoins = _days[targetIndex]['coins'] as double;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('royal_signin_days', _signedDays);
    await prefs.setString('royal_signin_last_date', todayStr);

    if (!mounted) return;

    context.read<ProfileBloc>().add(
          ClaimDailyRewardEvent(
            dayNumber: _signedDays,
            rewardCoins: rewardCoins,
          ),
        );

    setState(() {
      _claimedToday = true;
    });

    widget.onClaimed?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Claimed ${rewardCoins.toInt()} Coins! Saved in Supabase.'),
        backgroundColor: AppColors.gemEmerald,
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(child: CircularProgressIndicator(color: AppColors.goldCoin)),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Main White Card
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subtitle
                RichText(
                  text: TextSpan(
                    text: 'You have signed in for ',
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '$_signedDays',
                        style: const TextStyle(
                          color: AppColors.gemEmerald,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' days'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 7 Days Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: List.generate(_days.length, (index) {
                    final item = _days[index];
                    final bool isSpecial = item['isSpecial'] == true;
                    final bool isClaimed = index < (_signedDays - (_claimedToday ? 0 : 1));
                    final bool isCurrent = index == (_signedDays - (_claimedToday ? 1 : 0));
                    final coins = (item['coins'] as double).toInt();

                    return Container(
                      width: isSpecial ? 160 : 68,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isSpecial
                            ? const Color(0xFFFFF7E6)
                            : (isClaimed ? const Color(0xFFE8F7F2) : const Color(0xFFF3FAF7)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.goldCoin
                              : (isSpecial
                                  ? AppColors.goldCoin.withValues(alpha: 0.5)
                                  : (isClaimed
                                      ? AppColors.gemEmerald.withValues(alpha: 0.4)
                                      : Colors.transparent)),
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (isClaimed)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.gemEmerald,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    color: isSpecial
                                        ? const Color(0xFFD97706)
                                        : AppColors.gemEmerald,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Icon(Icons.monetization_on,
                                    color: AppColors.goldCoin, size: 20),
                                const SizedBox(height: 2),
                                Text(
                                  '$coins',
                                  style: TextStyle(
                                    color: isSpecial
                                        ? const Color(0xFFB45309)
                                        : const Color(0xFF0D5E46),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Big Button: Sign-in PK / Claimed
                GestureDetector(
                  onTap: _claimReward,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _claimedToday
                            ? [Colors.grey.shade400, Colors.grey.shade600]
                            : [const Color(0xFFFF9900), const Color(0xFFFF5500)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (_claimedToday ? Colors.grey : const Color(0xFFFF5500))
                              .withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _claimedToday ? 'Claimed Today ✓' : 'Sign-in & Claim Coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Peeking Cat Mascot with Ribbon
          Positioned(
            top: 0,
            child: Column(
              children: [
                // Cat head
                Container(
                  width: 90,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 48)),
                  ),
                ),
                // Ribbon: Sign-in Reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26D07C), Color(0xFF109B5B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF109B5B).withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Sign-in Reward',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close Button on top right
          Positioned(
            top: 70,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
