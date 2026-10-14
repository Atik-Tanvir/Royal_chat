import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';

class CoinsWalletPage extends StatelessWidget {
  final String currentBalance;

  const CoinsWalletPage({super.key, this.currentBalance = '161,480'});

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _TopUpBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: Column(
        children: [
          // Top Golden Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 36,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFAE19), Color(0xFFFF9100)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Column(
              children: [
                // Nav bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coins transaction records up to date.')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Balance Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top-Up Button (Floating overlapping pill)
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GestureDetector(
                onTap: () => _showTopUpSheet(context),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5722).withOpacity(0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Top-up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // "How to get 🪙" Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
                Row(
                  children: [
                    const Text(
                      'How to get ',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
                  ],
                ),
                const SizedBox(height: 12),

                // 1. Play BlockMe
                _buildTaskTile(
                  iconEmoji: '🧩',
                  title: 'Play BlockMe',
                  subtitle: '4-Line Clear to earn 50,000 🪙',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // 2. Top Rank Daily
                _buildTaskTile(
                  iconEmoji: '🏆',
                  title: 'Top Rank Daily',
                  subtitle: 'Top Player Earn 18.5M 🪙',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                    );
                  },
                ),

                // 3. Play multiplayer games
                _buildTaskTile(
                  iconEmoji: '🎮',
                  title: 'Play multiplayer games',
                  subtitle: 'Win More Coins',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // 4. Top Offers
                _buildTaskTile(
                  iconEmoji: '📋',
                  title: 'Top Offers',
                  subtitle: 'Complete Offers to Earn Coins',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening partner offers wall...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile({
    required String iconEmoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 24),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _TopUpBottomSheet extends StatelessWidget {
  const _TopUpBottomSheet();

  @override
  Widget build(BuildContext context) {
    final packages = [
      {'coins': '10,000', 'bonus': '+7,500', 'price': '\$0.99'},
      {'coins': '55,000', 'bonus': '+41,250', 'price': '\$4.99'},
      {'coins': '230,000', 'bonus': '+172,500', 'price': '\$19.99'},
      {'coins': '600,000', 'bonus': '+450,000', 'price': '\$49.99'},
      {'coins': '1,300,000', 'bonus': '+975,000', 'price': '\$99.99'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top-up Coins (+75% First Recharge)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldCoin.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          pkg['coins']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      pkg['bonus']!,
                      style: const TextStyle(color: Color(0xFFE11D48), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pkg['price']!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
