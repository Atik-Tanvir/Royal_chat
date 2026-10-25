import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/services/r2_storage_service.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/config/supabase_config.dart';

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

  void _showEditProfileSheet(BuildContext context, String currentName, String currentAvatar) {
    final nameController = TextEditingController(text: currentName);
    String avatarUrl = currentAvatar;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0F2B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Royal Profile',
                        style: TextStyle(color: AppColors.goldCoin, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white60),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar Picker Circle
                  Center(
                    child: GestureDetector(
                      onTap: isUploading
                          ? null
                          : () async {
                              try {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                                if (file == null) return;

                                setModalState(() => isUploading = true);
                                final bytes = await file.readAsBytes();
                                final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
                                final user = SupabaseConfig.client.auth.currentUser;
                                final currentUid = user?.id ?? widget.userId;
                                final uploadedUrl = await R2StorageService.instance.uploadAvatar(
                                  bytes: bytes,
                                  userId: currentUid,
                                  extension: ext,
                                );

                                setModalState(() {
                                  if (uploadedUrl != null) avatarUrl = uploadedUrl;
                                  isUploading = false;
                                });
                              } catch (e) {
                                setModalState(() => isUploading = false);
                              }
                            },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.goldCoin, width: 2),
                              image: avatarUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                                  : null,
                              color: const Color(0xFF07382D),
                            ),
                            child: avatarUrl.isEmpty
                                ? const Center(child: RoyalBrandLogo(size: 50))
                                : null,
                          ),
                          if (isUploading)
                            const CircularProgressIndicator(color: AppColors.gemEmerald)
                          else
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppColors.gemEmerald, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nickname Input
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Display Nickname',
                      labelStyle: const TextStyle(color: Colors.white70),
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
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) return;

                      context.read<ProfileBloc>().add(
                            UpdateProfileDetailsEvent(
                              nickname: newName,
                              avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                            ),
                          );

                      final activeUid = widget.userId.isNotEmpty
                          ? widget.userId
                          : (AuthSessionManager.currentUserId ?? '');

                      AuthSessionManager.saveSession(
                        userId: activeUid,
                        name: newName,
                        email: AuthSessionManager.currentUserEmail ?? '',
                        avatarUrl: avatarUrl,
                      );

                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated and saved to Supabase!'),
                          backgroundColor: AppColors.gemEmerald,
                        ),
                      );
                    },
                    child: const Text('Save Profile Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
                        onPressed: () => _showEditProfileSheet(context, currentUsername, currentAvatar),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(dynamic profile, String name, String avatar) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Avatar + Name + Gender/Age Row
        Row(
          children: [
            avatar.isNotEmpty
                ? CircleAvatar(radius: 28, backgroundImage: NetworkImage(avatar))
                : const CustomAvatar(radius: 28),
            const SizedBox(width: 14),
            Column(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0072FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    profile.gender ?? '♂ 19',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Personal signature
        const Text(
          'Royal Chat Live official verified member',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Country & Language Chips
        Row(
          children: [
            _buildBadgeChip('🇧🇩 ${profile.country ?? 'Bangladesh'}'),
            const SizedBox(width: 8),
            _buildBadgeChip('🌐 English'),
          ],
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
                            '👑 LV${profile.level ?? 1}',
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
}
