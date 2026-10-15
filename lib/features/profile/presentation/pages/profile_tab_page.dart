import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/wallet_card_widget.dart';
import '../widgets/withdrawal_ticker_widget.dart';
import '../widgets/signin_reward_dialog.dart';
import 'coins_wallet_page.dart';
import 'user_detail_page.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../../../auth/presentation/pages/login_page.dart';

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
          // Avatar with Royal VIP Frame
          CustomAvatar(
            imageUrl: profile.avatarUrl,
            radius: 36,
            hasVipFrame: true,
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
          colors: [Color(0xFFFFDF00), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoyalBrandLogo(size: 13),
          SizedBox(width: 3),
          Text(
            'VIP',
            style: TextStyle(
              color: Colors.black,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconColor: Colors.redAccent,
            title: 'Sign Out (Switch Account)',
            onTap: () async {
              context.read<ProfileBloc>().add(SignOutEvent());
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _WithdrawalModalSheet(),
    );
  }
}

class _WithdrawalModalSheet extends StatefulWidget {
  const _WithdrawalModalSheet();

  @override
  State<_WithdrawalModalSheet> createState() => _WithdrawalModalSheetState();
}

class _WithdrawalModalSheetState extends State<_WithdrawalModalSheet> {
  String _selectedGateway = 'bKash';
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _gemsController = TextEditingController(text: '1000');

  @override
  void dispose() {
    _accountController.dispose();
    _gemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final currentGems = state.profile.gemBalance;
        final double gemsToWithdraw = double.tryParse(_gemsController.text) ?? 1000.0;
        final double usdAmount = gemsToWithdraw / 1000.0;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.dialogSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Withdraw Gems to Cash', style: AppTextStyles.titleBold.copyWith(color: AppColors.gemCyan)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Balance: ${currentGems.toInt()} Gems (~ \$${(currentGems / 1000).toStringAsFixed(2)})',
                  style: const TextStyle(color: AppColors.goldCoin, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Gateway Selector
                const Text('Payout Method', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['bKash', 'Nagad', 'Rocket', 'USDT'].map((gateway) {
                    final isSel = _selectedGateway == gateway;
                    return ChoiceChip(
                      label: Text(gateway),
                      selected: isSel,
                      selectedColor: AppColors.gemEmerald,
                      backgroundColor: Colors.white10,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _selectedGateway = gateway),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Account Number Input
                TextField(
                  controller: _accountController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '$_selectedGateway Account Number / Address',
                    labelStyle: const TextStyle(color: Colors.white60),
                    hintText: _selectedGateway == 'USDT' ? 'TRC20 Wallet Address' : '017XXXXXXXX',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Gems Input
                TextField(
                  controller: _gemsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Gems Amount (Min: 1000)',
                    labelStyle: const TextStyle(color: Colors.white60),
                    helperText: 'You will receive: \$$usdAmount USD',
                    helperStyle: const TextStyle(color: Color(0xFF10B981)),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gemEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final gems = double.tryParse(_gemsController.text) ?? 0;
                    if (gems < 1000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Minimum withdrawal is 1,000 Gems (\$1.00 USD)')),
                      );
                      return;
                    }

                    if (_accountController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your receiving account number')),
                      );
                      return;
                    }

                    if (currentGems < gems) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insufficient gem balance. Earn gems in voice rooms!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    context.read<ProfileBloc>().add(
                          WithdrawGemsEvent(
                            gems,
                            gateway: _selectedGateway,
                            accountNumber: _accountController.text.trim(),
                          ),
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Withdrawal request for \$$usdAmount USD submitted to Supabase!'),
                        backgroundColor: AppColors.gemEmerald,
                      ),
                    );
                  },
                  child: const Text(
                    'Submit Withdrawal Request',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
