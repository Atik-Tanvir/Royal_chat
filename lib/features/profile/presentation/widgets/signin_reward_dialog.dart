import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
  int _signedDays = 2;
  bool _claimedToday = false;

  final List<Map<String, dynamic>> _days = [
    {'day': 'Day 1', 'coins': '2,000', 'claimed': true},
    {'day': 'Day 2', 'coins': '2,500', 'claimed': true},
    {'day': 'Day 3', 'coins': '3,000', 'claimed': false},
    {'day': 'Day 4', 'coins': '3,500', 'claimed': false},
    {'day': 'Day 5', 'coins': '4,000', 'claimed': false},
    {'day': 'Day 6', 'coins': '4,500', 'claimed': false},
    {'day': 'Day 7+', 'coins': '5,000', 'claimed': false, 'isSpecial': true},
  ];

  void _claimReward() {
    if (_claimedToday) return;

    setState(() {
      _signedDays += 1;
      _claimedToday = true;
      _days[2]['claimed'] = true;
    });

    widget.onClaimed?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Claimed 3,000 Coins from Sign-in PK!'),
        backgroundColor: AppColors.gemEmerald,
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.black.withOpacity(0.35),
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
                    final bool claimed = item['claimed'] as bool;

                    return Container(
                      width: isSpecial ? 160 : 68,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isSpecial
                            ? const Color(0xFFFFF7E6)
                            : (claimed ? const Color(0xFFE8F7F2) : const Color(0xFFF3FAF7)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSpecial
                              ? AppColors.goldCoin.withOpacity(0.5)
                              : (claimed
                                  ? AppColors.gemEmerald.withOpacity(0.4)
                                  : Colors.transparent),
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (claimed)
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
                                  item['coins'] as String,
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

                // Big Orange Button: Sign-in PK
                GestureDetector(
                  onTap: _claimReward,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9900), Color(0xFFFF5500)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5500).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _claimedToday ? 'Claimed Today' : 'Sign-in PK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
                        color: const Color(0xFF109B5B).withOpacity(0.5),
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
