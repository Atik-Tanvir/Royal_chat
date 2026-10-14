import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cat_mascot_widget.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/wallet_card_widget.dart';
import '../widgets/withdrawal_ticker_widget.dart';
import '../widgets/signin_reward_dialog.dart';
import 'coins_wallet_page.dart';
import 'user_detail_page.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = state.profile;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, profile),
                const SizedBox(height: 20),
                _buildSocialStats(profile),
                const SizedBox(height: 24),
                _buildWalletSection(context, profile),
                const SizedBox(height: 14),
                WithdrawalTickerWidget(text: state.recentWithdrawalText),
                const SizedBox(height: 16),
                _buildFirstRechargeBanner(context),
                const SizedBox(height: 20),
                _buildMenuList(context),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailPage(
              username: profile.nickname,
              userId: profile.userId,
              countryFlag: '🇧🇩',
              countryName: profile.country,
            ),
          ),
        );
      },
      child: Row(
        children: [
          // Avatar with stylish hat matching Screenshot 1
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: CatMascotWidget(size: 64, withHat: true),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.nickname,
                      style: AppTextStyles.headerMedium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.white60, size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                // Badges row: Country, Gender/Age, Level, VIP
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildPillBadge(
                      color: const Color(0xFF137752),
                      icon: Icons.circle,
                      iconColor: Colors.red,
                      label: profile.country,
                    ),
                    _buildPillBadge(
                      color: const Color(0xFF1976D2),
                      label: profile.gender,
                    ),
                    _buildDiamondBadge('LV${profile.level}'),
                    _buildVipBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge({
    required Color color,
    required String label,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 8, color: iconColor ?? Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF37474F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gemCyan, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, size: 10, color: AppColors.gemCyan),
          const SizedBox(width: 2),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'VIP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSocialStats(UserProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('${profile.friendsCount}', 'Friends'),
        _buildStatItem('${profile.followingCount}', 'Following'),
        _buildStatItem('${profile.fansCount}', 'Fans'),
        _buildStatItem('${profile.visitorsCount}', 'Visitors'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.statNumber.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildWalletSection(BuildContext context, UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Wallet',
              style: AppTextStyles.titleBold.copyWith(fontSize: 17),
            ),
            const Icon(Icons.help_outline_rounded, color: Colors.white60, size: 18),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            WalletCardWidget(
              type: WalletCardType.gem,
              amount: profile.formattedGems,
              onTap: () {
                _showWithdrawModal(context);
              },
            ),
            const SizedBox(width: 12),
            WalletCardWidget(
              type: WalletCardType.coin,
              amount: profile.formattedCoins,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFirstRechargeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6E40), Color(0xFFFF3D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3D00).withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'First Recharge +75%',
                  style: AppTextStyles.titleBold.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBundleItem(icon: Icons.card_giftcard, label: '\$1', isSpecial: true),
                const Text('+', style: TextStyle(color: Colors.white70, fontSize: 18)),
                _buildBundleItem(icon: Icons.monetization_on, label: '796.2K'),
                const Text('+', style: TextStyle(color: Colors.white70, fontSize: 18)),
                _buildBundleItem(icon: Icons.diamond, label: 'LV1'),
                const Text('+', style: TextStyle(color: Colors.white70, fontSize: 18)),
                _buildBundleItem(icon: Icons.circle_outlined, label: 'Frame'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleItem({required IconData icon, required String label, bool isSpecial = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSpecial ? AppColors.accentRed : AppColors.goldCoin, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSpecial ? AppColors.accentRed : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_add_rounded,
            iconColor: AppColors.gemEmerald,
            title: 'Invite',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '10K 💎 / 👤',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gemEmerald, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardPage(initialTabIndex: 3),
                ),
              );
            },
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          _buildMenuItem(
            icon: Icons.verified_user_rounded,
            iconColor: AppColors.gemCyan,
            title: 'Top Offers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardPage(initialTabIndex: 0),
                ),
              );
            },
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          _buildMenuItem(
            icon: Icons.event_note_rounded,
            iconColor: AppColors.accentOrange,
            title: 'Sign-in PK',
            onTap: () {
              SignInRewardDialog.show(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      trailing: trailingWidget ?? const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
    );
  }

  void _showWithdrawModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.dialogSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Withdraw Gems to Cash', style: AppTextStyles.titleBold.copyWith(color: AppColors.gemCyan)),
            const SizedBox(height: 8),
            Text(
              'Minimum cashout: 1,000 Gems (\$1.00 USD). Supported via bKash, Nagad, USDT, Payoneer.',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gemEmerald),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Request Withdrawal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
