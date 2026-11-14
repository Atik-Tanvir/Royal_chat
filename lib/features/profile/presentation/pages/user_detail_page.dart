import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../../calls/presentation/pages/one_on_one_call_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/edit_profile_sheet.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String username;
  final String countryFlag;
  final String countryName;

  const UserDetailPage({
    super.key,
    this.userId = '',
    this.username = '',
    this.countryFlag = '🇧🇩',
    this.countryName = 'Bangladesh',
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProfileSheet(BuildContext context) {
    EditProfileSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final currentUsername = profile.nickname.isNotEmpty ? profile.nickname : widget.username;
        final currentAvatar = profile.avatarUrl;

        return Scaffold(
          backgroundColor: const Color(0xFF031A14),
          body: Stack(
            children: [
              // Top Cover
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 380,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF031A14), Color(0xFF07382D)],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Royal Emblem or Real Avatar
                      Positioned(
                        bottom: 30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFF0F7658), Color(0xFF04221B)],
                            ),
                            border: Border.all(color: AppColors.borderGold, width: 2.5),
                            image: currentAvatar.isNotEmpty
                                ? DecorationImage(image: NetworkImage(currentAvatar), fit: BoxFit.cover)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldCoin.withValues(alpha: 0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: currentAvatar.isEmpty
                              ? const Center(child: RoyalBrandLogo(size: 96))
                              : null,
                        ),
                      ),

                      // Top User ID & Online Pill
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID:${profile.userId}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Online',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Nav Buttons (Back & Edit)
              Positioned(
                top: MediaQuery.of(context).padding.top + 6,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      currentUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        onPressed: () => _showEditProfileSheet(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Sheet Card with Info / Moments Tabs
              Positioned.fill(
                top: 320,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF063025),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, -6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Subtabs Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: AppColors.goldCoin,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: AppColors.goldCoin,
                          labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          unselectedLabelColor: Colors.white54,
                          unselectedLabelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                          tabs: const [
                            Tab(text: 'Info'),
                            Tab(text: 'Moments'),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),

                      // Tab Views
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInfoTab(profile, currentUsername, currentAvatar),
                            _buildMomentsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar for 1v1 Calls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomCallBar(context, currentUsername, currentAvatar),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(UserProfile profile, String name, String avatar) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        // Avatar + Name + Gender/Age Row
        Row(
          children: [
            avatar.isNotEmpty
                ? CircleAvatar(radius: 28, backgroundImage: NetworkImage(avatar))
                : const CustomAvatar(radius: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          profile.gender.isNotEmpty ? profile.gender : '♂ 20',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F7658),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${profile.countryFlag} ${profile.country}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.goldCoin, size: 26),
              tooltip: 'Edit Profile',
              onPressed: () => _showEditProfileSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Personal bio
        Text(
          profile.bio.isNotEmpty
              ? profile.bio
              : 'Royal Chat Live official verified member ✨',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),

        // Country & Language Chips
        Row(
          children: [
            _buildBadgeChip('${profile.countryFlag} ${profile.country}'),
            const SizedBox(width: 8),
            _buildBadgeChip('🌐 ${profile.language}'),
          ],
        ),
        const SizedBox(height: 16),

        // Quick Edit Profile Banner Button
        OutlinedButton.icon(
          onPressed: () => _showEditProfileSheet(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.goldCoin, width: 1.2),
            foregroundColor: AppColors.goldCoin,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.edit_rounded, size: 16),
          label: const Text(
            'Edit Personal Info, Country & Language',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),

        // Wealth Level & Charm Level Cards
        Row(
          children: [
            // Wealth Level Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F3E32), Color(0xFF08261F)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gemEmerald.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.gemEmerald, size: 30),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wealth Level', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.gemEmerald,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '👑 LV${profile.level}',
                            style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Charm Level Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1C40), Color(0xFF1A1024)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.purpleAccent, size: 30),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Charm Level', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '💎 LV2',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMomentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.goldCoin, size: 36),
          ),
          const SizedBox(height: 12),
          const Text(
            'Moments synced with Supabase',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBottomCallBar(BuildContext context, String currentUsername, String currentAvatar) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: const Color(0xFF031A14).withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFF1C3830), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice Call Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OneOnOneCallPage(
                      calleeId: widget.userId.isNotEmpty ? widget.userId : 'user_target',
                      calleeName: currentUsername,
                      calleeAvatar: currentAvatar,
                      calleeCountry: widget.countryFlag,
                      isVideoCall: false,
                      gemsPerMinute: 120,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text('Voice (120 💎/m)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5E42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.gemEmerald, width: 1),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Video Call Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OneOnOneCallPage(
                      calleeId: widget.userId.isNotEmpty ? widget.userId : 'user_target',
                      calleeName: currentUsername,
                      calleeAvatar: currentAvatar,
                      calleeCountry: widget.countryFlag,
                      isVideoCall: true,
                      gemsPerMinute: 240,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.videocam_rounded, size: 20),
              label: const Text('Video (240 💎/m)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldCoin,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
