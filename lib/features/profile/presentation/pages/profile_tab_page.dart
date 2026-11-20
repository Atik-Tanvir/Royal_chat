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
import 'wallet_transactions_page.dart';
import '../widgets/diamond_conversion_sheet.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'task_center_page.dart';
import 'backpack_store_page.dart';
import '../../../games/presentation/pages/bucket_prediction_game_page.dart';
import '../../../moments/presentation/pages/social_profile_page.dart';
import '../widgets/edit_profile_sheet.dart';

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
                const SizedBox(height: 16),
                _buildGemgalaFeatureRow(context),
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
              countryFlag: profile.countryFlag,
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
                    Flexible(
                      child: Text(
                        profile.nickname,
                        style: AppTextStyles.headerMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.white60, size: 20),
                    const Spacer(),
                    InkWell(
                      onTap: () => EditProfileSheet.show(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldCoin.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.5), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded, color: AppColors.goldCoin, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.goldCoin,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Badges row: Country, Gender/Age, Language, Level, VIP
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildPillBadge(
                      color: const Color(0xFF137752),
                      label: '${profile.countryFlag} ${profile.country}',
                    ),
                    _buildPillBadge(
                      color: const Color(0xFF1976D2),
                      label: profile.gender,
                    ),
                    _buildPillBadge(
                      color: const Color(0xFF5B21B6),
                      label: '🌐 ${profile.language}',
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WalletTransactionsPage(initialTabIndex: 0),
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: AppColors.goldCoin, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Records',
                    style: TextStyle(
                      color: AppColors.goldCoin,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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

  
  Widget _buildGemgalaFeatureRow(BuildContext context) {
    return Row(
      children: [
        _buildFeatureCard(
          context: context,
          icon: Icons.assignment_turned_in_rounded,
          title: 'Tasks',
          subtitle: 'Chests 🎁',
          color: const Color(0xFF00E676),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskCenterPage()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildFeatureCard(
          context: context,
          icon: Icons.gamepad_rounded,
          title: 'Bucket Spin',
          subtitle: 'Win 2x 🪣',
          color: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BucketPredictionGamePage()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildFeatureCard(
          context: context,
          icon: Icons.storefront_rounded,
          title: 'Store',
          subtitle: 'Rides 👑',
          color: const Color(0xFF00E5FF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackpackStorePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.18),
                const Color(0xFF071C15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Material(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.dynamic_feed_rounded,
            iconColor: AppColors.accentOrange,
            title: 'My Social Profile (Posts & Photos)',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accentOrange, width: 0.8),
                  ),
                  child: const Text(
                    'Moments',
                    style: TextStyle(color: AppColors.accentOrange, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SocialProfilePage()),
              );
            },
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          _buildMenuItem(
            icon: Icons.manage_accounts_rounded,
            iconColor: AppColors.goldCoin,
            title: 'Edit Profile & Personal Info',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldCoin.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldCoin, width: 0.8),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: AppColors.goldCoin, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
            onTap: () {
              EditProfileSheet.show(context);
            },
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
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
            icon: Icons.assignment_turned_in_rounded,
            iconColor: const Color(0xFF00E676),
            title: 'Task Center (Daily Missions)',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00E676), width: 0.8),
                  ),
                  child: const Text(
                    'Chests 🎁',
                    style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskCenterPage()),
              );
            },
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          _buildMenuItem(
            icon: Icons.gamepad_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Bucket Spin (8-Item Prediction)',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                  ),
                  child: const Text(
                    'Win 2x 🪣',
                    style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BucketPredictionGamePage()),
              );
            },
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          _buildMenuItem(
            icon: Icons.storefront_rounded,
            iconColor: const Color(0xFF00E5FF),
            title: 'Backpack & Mall (Frames & Rides)',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                  ),
                  child: const Text(
                    'VIP 👑',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackpackStorePage()),
              );
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
  String _selectedCountry = 'BD'; // 'BD' or 'IN'
  String _selectedGateway = 'bKash';
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gemsController = TextEditingController(text: '5000');

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    _gemsController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String country) {
    setState(() {
      _selectedCountry = country;
      if (country == 'BD') {
        _selectedGateway = 'bKash';
      } else {
        _selectedGateway = 'Google Pay';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final currentGems = state.profile.gemBalance;
        final double gemsToWithdraw = double.tryParse(_gemsController.text) ?? 5000.0;
        final double usdAmount = gemsToWithdraw / 1000.0;
        final double localCurrencyAmount = _selectedCountry == 'BD'
            ? usdAmount * 120.0 // 1 USD = 120 BDT
            : usdAmount * 86.0; // 1 USD = 86 INR
        final String localCurrencySymbol = _selectedCountry == 'BD' ? '৳' : '₹';
        final String localCurrencyCode = _selectedCountry == 'BD' ? 'BDT' : 'INR';
        final bool hasMinBalance = currentGems >= 5000.0;

        final bdGateways = ['bKash', 'Nagad'];
        final inGateways = ['Google Pay', 'Paytm', 'PhonePe'];
        final currentGateways = _selectedCountry == 'BD' ? bdGateways : inGateways;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(22),
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
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.gemCyan, size: 22),
                          const SizedBox(width: 8),
                          Text('Withdraw Gems to Cash', style: AppTextStyles.titleBold.copyWith(color: AppColors.gemCyan)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your Balance: ${currentGems.toInt()} Gems (~ \$${(currentGems / 1000).toStringAsFixed(2)})',
                    style: const TextStyle(color: AppColors.goldCoin, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Bar: Exchange to Coins & Payout History
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gemCyan,
                            side: const BorderSide(color: AppColors.gemCyan),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                          label: const Text('Exchange to Coins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(context);
                            DiamondConversionSheet.show(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.goldCoin,
                            side: const BorderSide(color: AppColors.goldCoin),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(Icons.history_rounded, size: 18),
                          label: const Text('Payout History', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WalletTransactionsPage(initialTabIndex: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Under-minimum balance warning
                  if (!hasMinBalance)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Minimum payout is \$5.00 USD (5,000 Gems). Your balance is ${currentGems.toInt()} Gems (\$' +
                                  (currentGems / 1000).toStringAsFixed(2) +
                                  '). Earn more diamonds in party rooms before requesting a withdrawal.',
                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Country Selection
                  const Text('Select Payout Country', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onCountryChanged('BD'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedCountry == 'BD' ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedCountry == 'BD' ? AppColors.gemEmerald : Colors.white12,
                                width: _selectedCountry == 'BD' ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🇧🇩', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  'Bangladesh',
                                  style: TextStyle(
                                    color: _selectedCountry == 'BD' ? Colors.white : Colors.white60,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onCountryChanged('IN'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedCountry == 'IN' ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedCountry == 'IN' ? AppColors.gemEmerald : Colors.white12,
                                width: _selectedCountry == 'IN' ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  'India',
                                  style: TextStyle(
                                    color: _selectedCountry == 'IN' ? Colors.white : Colors.white60,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Gateway Selector
                  Text(
                    _selectedCountry == 'BD' ? 'Bangladesh Payment Method' : 'India Payment Method',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: currentGateways.map((gateway) {
                      final isSel = _selectedGateway == gateway;
                      return ChoiceChip(
                        label: Text(gateway),
                        selected: isSel,
                        selectedColor: AppColors.gemEmerald,
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) => setState(() => _selectedGateway = gateway),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Account / Phone Number Input
                  TextField(
                    controller: _accountController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: _selectedCountry == 'BD'
                          ? '$_selectedGateway Mobile Number (11 Digits)'
                          : '$_selectedGateway Phone Number / UPI ID',
                      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                      hintText: _selectedCountry == 'BD'
                          ? 'e.g. 01712345678'
                          : 'e.g. 9876543210 or yourname@oksbi',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Account Holder Name
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Account Holder Full Name',
                      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                      hintText: 'Enter name registered with $_selectedGateway',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gems Input
                  TextField(
                    controller: _gemsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Gems Amount (Min: 5,000 = \$5.00 USD)',
                      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                      helperText: 'Payout: \$${usdAmount.toStringAsFixed(2)} USD  ≈  $localCurrencySymbol${localCurrencyAmount.toStringAsFixed(0)} $localCurrencyCode',
                      helperStyle: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Owner note info
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      '📌 Owner/Admin will transfer $localCurrencySymbol${localCurrencyAmount.toStringAsFixed(0)} $localCurrencyCode to your $_selectedGateway account upon review. Minimum threshold is strictly \$5.00 USD.',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasMinBalance ? AppColors.gemEmerald : Colors.white24,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: !hasMinBalance
                        ? null
                        : () {
                            final gems = double.tryParse(_gemsController.text) ?? 0;
                            if (gems < 5000) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Minimum withdrawal is strictly 5,000 Gems (\$5.00 USD)'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final accountNum = _accountController.text.trim();
                            if (accountNum.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_selectedCountry == 'BD'
                                      ? 'Please enter your 11-digit $_selectedGateway number'
                                      : 'Please enter your $_selectedGateway UPI ID or Phone'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            if (_nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter the account holder full name'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            // Strict format validation
                            if (_selectedCountry == 'BD') {
                              final bdRegex = RegExp(r'^01[3-9]\d{8}$');
                              if (!bdRegex.hasMatch(accountNum)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid Bangladesh number! Must be 11 digits starting with 01 (e.g. 017XXXXXXXX)'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                            } else {
                              final isUpi = accountNum.contains('@') && accountNum.length >= 5;
                              final is10DigitPhone = RegExp(r'^\d{10}$').hasMatch(accountNum);
                              if (!isUpi && !is10DigitPhone) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid Indian payment details! Enter a 10-digit phone number or UPI ID (e.g. user@bank)'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                            }

                            if (currentGems < gems) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Insufficient gem balance. You have ${currentGems.toInt()} Gems.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            context.read<ProfileBloc>().add(
                                  WithdrawGemsEvent(
                                    gems,
                                    gateway: _selectedGateway,
                                    accountNumber: accountNum,
                                    accountName: _nameController.text.trim(),
                                    country: _selectedCountry,
                                  ),
                                );

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Withdrawal request for \$${usdAmount.toStringAsFixed(2)} USD ($localCurrencySymbol${localCurrencyAmount.toStringAsFixed(0)} $localCurrencyCode) submitted!'),
                                backgroundColor: AppColors.gemEmerald,
                                action: SnackBarAction(
                                  label: 'Track Status',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const WalletTransactionsPage(initialTabIndex: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                    child: Text(
                      hasMinBalance
                          ? 'Submit Withdrawal Request (\$${usdAmount.toStringAsFixed(2)})'
                          : 'Requires at least \$5.00 USD (5,000 Gems)',
                      style: TextStyle(
                        color: hasMinBalance ? Colors.black : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
