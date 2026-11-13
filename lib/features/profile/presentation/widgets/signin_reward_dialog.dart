import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';

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

      bool claimed = false;
      int currentDays = days;

      if (lastDate.isNotEmpty && lastDate == todayStr) {
        claimed = true;
      }

      if (currentDays == 0) {
        currentDays = 1;
      }

      if (mounted) {
        setState(() {
          _signedDays = currentDays;
          _claimedToday = claimed;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claimReward() async {
    if (_isLoading) return;

    if (_claimedToday) {
      // If already claimed today, clicking "Sign-in PK" opens Leaderboard ranking
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LeaderboardPage(initialTabIndex: 1),
        ),
      );
      return;
    }

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
        content: Text('🎉 Claimed ${rewardCoins.toInt()} Coins! Signed in for Day $_signedDays.'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // After claiming, automatically open the Leaderboard/Game ranking page matching screenshot
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LeaderboardPage(initialTabIndex: 1),
        ),
      );
    }
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Main White Modal Card
          Container(
            margin: const EdgeInsets.only(top: 65),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "You have signed in for X days"
                RichText(
                  text: TextSpan(
                    text: 'You have signed in for ',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: '$_signedDays',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const TextSpan(text: ' days'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Row 1: Day 1, Day 2, Day 3, Day 4
                Row(
                  children: [
                    _buildDailyCard(0),
                    const SizedBox(width: 8),
                    _buildDailyCard(1),
                    const SizedBox(width: 8),
                    _buildDailyCard(2),
                    const SizedBox(width: 8),
                    _buildDailyCard(3),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: Day 5, Day 6, Day 7+
                Row(
                  children: [
                    _buildDailyCard(4),
                    const SizedBox(width: 8),
                    _buildDailyCard(5),
                    const SizedBox(width: 8),
                    _buildSpecialCard(6),
                  ],
                ),

                const SizedBox(height: 22),

                // Bottom Action Button: "Sign-in PK"
                GestureDetector(
                  onTap: _claimReward,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7043).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _claimedToday ? 'Sign-in PK (Claimed ✓)' : 'Sign-in PK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Peeking Cat Mascot with Turquoise Ribbon Banner
          Positioned(
            top: 0,
            child: _buildMascotHeader(),
          ),

          // Modal Close Button '✕' on top right
          Positioned(
            top: 76,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(int index) {
    final item = _days[index];
    final bool isClaimed = index < _signedDays || (index == _signedDays - 1 && _claimedToday);
    final coins = (item['coins'] as double).toInt();

    return Expanded(
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCCFBF1),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (isClaimed)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF14B8A6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 13, color: Colors.white),
                  ),
                ),
              ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['day'] as String,
                    style: const TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildCoinGraphic(),
                  const SizedBox(height: 4),
                  Text(
                    _formatCoins(coins),
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialCard(int index) {
    final item = _days[index];
    final bool isClaimed = index < _signedDays || (index == _signedDays - 1 && _claimedToday);
    final coins = (item['coins'] as double).toInt();

    return Expanded(
      flex: 2,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFDE68A),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (isClaimed)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF14B8A6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
              ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Day 7+',
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildCoinGraphic(size: 26),
                  const SizedBox(height: 4),
                  Text(
                    _formatCoins(coins),
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinGraphic({double size = 22}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFEE58), Color(0xFFFFA000)],
          stops: [0.3, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA000).withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFF9C4), width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: size * 0.55,
          color: const Color(0xFF78350F).withValues(alpha: 0.6),
        ),
      ),
    );
  }

  String _formatCoins(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildMascotHeader() {
    return SizedBox(
      height: 120,
      width: 260,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Golden Aura Glow
          Positioned(
            top: 6,
            child: Container(
              width: 140,
              height: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD54F).withValues(alpha: 0.6),
                    const Color(0xFFFFE082).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating gems & coins
          const Positioned(
            left: 20,
            top: 40,
            child: Icon(Icons.diamond, color: Color(0xFF34D399), size: 18),
          ),
          const Positioned(
            right: 22,
            top: 42,
            child: Icon(Icons.monetization_on, color: Color(0xFFFBBF24), size: 18),
          ),
          const Positioned(
            left: 54,
            top: 20,
            child: Icon(Icons.star_rounded, color: Color(0xFFFDE047), size: 15),
          ),
          const Positioned(
            right: 56,
            top: 22,
            child: Icon(Icons.diamond, color: Color(0xFF2DD4BF), size: 15),
          ),

          // Smiling Cat Illustration
          Positioned(
            top: 8,
            child: SizedBox(
              width: 110,
              height: 75,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Left Orange Ear
                  Positioned(
                    top: 0,
                    right: 20,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: Container(
                        width: 22,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right White Ear
                  Positioned(
                    top: 0,
                    left: 20,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: Container(
                        width: 22,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCDD2),
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // White Cat Face with Orange Spot
                  Positioned(
                    top: 12,
                    child: Container(
                      width: 82,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.elliptical(82, 56)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x20000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF97316),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  topRight: Radius.circular(28),
                                ),
                              ),
                            ),
                          ),
                          // Cute Happy Face: ^  ^ eyes, smiling mouth
                          Align(
                            alignment: const Alignment(0, 0.2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: Colors.black.withOpacity(0.85), width: 2),
                                        ),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Container(
                                      width: 12,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: Colors.black.withOpacity(0.85), width: 2),
                                        ),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  width: 7,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Left Paw
                  Positioned(
                    bottom: 0,
                    left: 25,
                    child: Container(
                      width: 14,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black12, width: 0.8),
                      ),
                    ),
                  ),
                  // Right Paw
                  Positioned(
                    bottom: 0,
                    right: 25,
                    child: Container(
                      width: 14,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black12, width: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Turquoise Ribbon Banner: "Sign-in Reward"
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6), Color(0xFF0D9488)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Sign-in Reward',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Color(0x40000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
