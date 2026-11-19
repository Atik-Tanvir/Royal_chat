import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/r2_storage_service.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/entities/moment_post.dart';
import '../../domain/entities/social_profile.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../widgets/moment_media_image.dart';
import '../widgets/moment_post_card.dart';
import 'create_moment_page.dart';

const List<List<Color>> kProfileCoverGradients = [
  [Color(0xFF0E6B47), Color(0xFF042D20)],
  [Color(0xFFE65100), Color(0xFF8E24AA)],
  [Color(0xFF4A148C), Color(0xFF1565C0)],
  [Color(0xFFC2185B), Color(0xFF6A1B9A)],
  [Color(0xFF00695C), Color(0xFF1B5E20)],
];

/// Dedicated Social Profile & Account Management screen.
/// Shows user's ID card, bio, stats, posts, uploaded photos, stories, and
/// profile management controls (edit avatar/cover/bio/handle).
class SocialProfilePage extends StatefulWidget {
  final String? userId;
  final MomentPost? fallbackPost;

  const SocialProfilePage({
    super.key,
    this.userId,
    this.fallbackPost,
  });

  @override
  State<SocialProfilePage> createState() => _SocialProfilePageState();
}

class _SocialProfilePageState extends State<SocialProfilePage> {
  SocialProfileDetails _resolveProfile(MomentsState state) {
    final myId = AuthSessionManager.currentUserId ?? 'royal_guest';
    final targetId = widget.userId ?? myId;
    final stored = state.profilesById[targetId];
    if (stored != null) return stored;

    if (targetId == myId && state.mySocialProfile != null) {
      return state.mySocialProfile!;
    }

    final post = widget.fallbackPost;
    final name = post?.authorName ?? 'Gamegala Player';
    final handleClean =
        name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return SocialProfileDetails(
      userId: targetId,
      usernameHandle: '@${handleClean.isEmpty ? 'player' : handleClean}',
      nickname: name,
      avatarUrl: post?.authorAvatar ?? '',
      location: post?.location ?? 'Bangladesh',
      countryFlag: post?.countryFlag ?? '🇧🇩',
      level: post?.authorLevel ?? 10,
      bio: 'Community member on Gamegala Moments.',
    );
  }

  void _openEditProfileSheet(
      BuildContext context, SocialProfileDetails profile) {
    final bloc = context.read<MomentsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _ManageSocialProfileSheet(profile: profile),
      ),
    );
  }

  void _openCreatePost(BuildContext context) {
    final bloc = context.read<MomentsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const CreateMomentPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentsBloc, MomentsState>(
      builder: (context, state) {
        final profile = _resolveProfile(state);
        final isMine = profile.userId == AuthSessionManager.currentUserId;
        final isFollowing = state.followedAuthorIds.contains(profile.userId);

        final userPosts = state.posts
            .where((p) => p.authorId == profile.userId)
            .toList();
        final userPhotos = <String>[
          for (final p in userPosts) ...p.imageUrls,
        ];
        final totalLoves =
            userPosts.fold<int>(0, (sum, p) => sum + p.likesCount);
        final totalShares =
            userPosts.fold<int>(0, (sum, p) => sum + p.sharesCount);
        final coverGradient = kProfileCoverGradients[
            profile.coverGradientIndex % kProfileCoverGradients.length];

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: const Color(0xFFF3F7F4),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 205,
                  pinned: true,
                  backgroundColor: coverGradient.first,
                  leading: IconButton(
                    icon: const CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.black38,
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    if (isMine)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextButton.icon(
                          onPressed: () =>
                              _openEditProfileSheet(context, profile),
                          icon: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 16),
                          label: const Text(
                            'Manage Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<MomentsBloc>().add(
                                ToggleFollowAuthorEvent(
                                  authorId: profile.userId,
                                  authorName: profile.nickname,
                                ),
                              ),
                          icon: Icon(
                            isFollowing
                                ? Icons.check_rounded
                                : Icons.person_add_alt_1_rounded,
                            size: 16,
                          ),
                          label: Text(isFollowing ? 'Following' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.white
                                : AppColors.accentOrange,
                            foregroundColor: isFollowing
                                ? AppColors.primaryGreen
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: coverGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        if (profile.coverImageUrl != null &&
                            profile.coverImageUrl!.isNotEmpty)
                          MomentMediaImage(
                            source: profile.coverImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.55),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomAvatar(
                                imageUrl: profile.avatarUrl,
                                fallbackName: profile.nickname,
                                radius: 38,
                                hasVipFrame: true,
                                countryFlag: profile.countryFlag,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile.nickname,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentOrange,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Lv.${profile.level}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      profile.usernameHandle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(
                                            ClipboardData(text: profile.userId));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('User ID copied to clipboard!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'ID: ${profile.userId}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.copy_rounded,
                                                color: Colors.white70,
                                                size: 12),
                                          ],
                                        ),
                                      ),
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

                // Bio + Stats + Quick Manage Row
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile.bio.isNotEmpty)
                          Text(
                            profile.bio,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 14,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 15, color: AppColors.primaryGreen),
                                const SizedBox(width: 4),
                                Text(
                                  profile.location,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  profile.joinedLabel,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7F4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _statTile('${userPosts.length}', 'Posts'),
                              _statTile('${userPhotos.length}', 'Photos'),
                              _statTile('$totalLoves', 'Loves'),
                              _statTile('${profile.followersCount}', 'Followers'),
                            ],
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: () => _openCreatePost(context),
                                  icon: const Icon(Icons.add_photo_alternate_rounded,
                                      size: 18, color: Colors.white),
                                  label: const Text(
                                    'Create Post',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: () => _openEditProfileSheet(context, profile),
                                  icon: const Icon(Icons.edit_rounded, size: 17),
                                  label: const Text(
                                    'Edit Profile',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryGreen,
                                    side: const BorderSide(color: AppColors.primaryGreen),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabHeaderDelegate(
                    const TabBar(
                      labelColor: AppColors.primaryGreen,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primaryGreen,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13),
                      tabs: [
                        Tab(text: 'Posts'),
                        Tab(text: 'Photos'),
                        Tab(text: 'About & ID'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  // 1. Posts Tab
                  userPosts.isEmpty
                      ? _emptyState(
                          icon: Icons.dynamic_feed_rounded,
                          title: 'No posts yet',
                          subtitle: isMine
                              ? 'Share a photo, game win, or status update!'
                              : '${profile.nickname} has not posted yet.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: userPosts.length,
                          itemBuilder: (_, idx) =>
                              MomentPostCard(post: userPosts[idx]),
                        ),

                  // 2. Photos Grid Tab
                  userPhotos.isEmpty
                      ? _emptyState(
                          icon: Icons.photo_library_outlined,
                          title: 'No uploaded photos',
                          subtitle:
                              'Photos from your moments posts appear here.',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(14),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: userPhotos.length,
                          itemBuilder: (ctx, idx) => GestureDetector(
                            onTap: () => _openMediaDialog(ctx, userPhotos[idx]),
                            child: MomentMediaImage(
                              source: userPhotos[idx],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                  // 3. About & ID Tab
                  ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      _aboutCard(
                        profile: profile,
                        postsCount: userPosts.length,
                        photosCount: userPhotos.length,
                        totalLoves: totalLoves,
                        totalShares: totalShares,
                        likedByMeCount: state.likedPostIds.length,
                        isMine: isMine,
                      ),
                      if (isMine) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Posts You Loved ❤️',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...state.posts
                            .where((p) => p.isLiked)
                            .map((p) => MomentPostCard(post: p)),
                        if (state.posts.every((p) => !p.isLiked))
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Tap ❤️ on any community post and it will be saved here!',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statTile(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutCard({
    required SocialProfileDetails profile,
    required int postsCount,
    required int photosCount,
    required int totalLoves,
    required int totalShares,
    required int likedByMeCount,
    required bool isMine,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account & ID Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.badge_rounded, 'User ID', profile.userId),
          _infoRow(Icons.alternate_email_rounded, 'Handle', profile.usernameHandle),
          _infoRow(Icons.person_rounded, 'Display Name', profile.nickname),
          _infoRow(Icons.location_city_rounded, 'Location', profile.location),
          _infoRow(Icons.star_rounded, 'Social Level', 'Level ${profile.level}'),
          _infoRow(Icons.article_rounded, 'Total Posts & Reposts', '$postsCount'),
          _infoRow(Icons.photo_library_rounded, 'Uploaded Photos', '$photosCount'),
          _infoRow(Icons.favorite_rounded, 'Total Loves Received', '$totalLoves'),
          _infoRow(Icons.share_rounded, 'Total Shares Received', '$totalShares'),
          if (isMine)
            _infoRow(Icons.bookmark_added_rounded, 'Posts You Loved',
                '$likedByMeCount'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMediaDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: MomentMediaImage(
                source: url,
                height: 360,
                width: 340,
                fit: BoxFit.contain,
              ),
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) => false;
}

class _ManageSocialProfileSheet extends StatefulWidget {
  final SocialProfileDetails profile;

  const _ManageSocialProfileSheet({required this.profile});

  @override
  State<_ManageSocialProfileSheet> createState() =>
      _ManageSocialProfileSheetState();
}

class _ManageSocialProfileSheetState extends State<_ManageSocialProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _handleController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late String _avatarUrl;
  String? _coverImageUrl;
  late int _coverGradientIndex;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.nickname);
    _handleController =
        TextEditingController(text: widget.profile.usernameHandle);
    _bioController = TextEditingController(text: widget.profile.bio);
    _locationController = TextEditingController(text: widget.profile.location);
    _avatarUrl = widget.profile.avatarUrl;
    _coverImageUrl = widget.profile.coverImageUrl;
    _coverGradientIndex = widget.profile.coverGradientIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final url = await R2StorageService.instance.uploadAvatar(
        bytes: bytes,
        userId: widget.profile.userId,
        extension: ext,
      );
      if (mounted && url != null) setState(() => _avatarUrl = url);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickCover() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final url = await R2StorageService.instance.uploadRoomCover(
        bytes: bytes,
        roomId: widget.profile.userId,
        extension: ext,
      );
      if (mounted && url != null) setState(() => _coverImageUrl = url);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _save() {
    context.read<MomentsBloc>().add(
          UpdateMySocialProfileEvent(
            nickname: _nameController.text,
            usernameHandle: _handleController.text,
            bio: _bioController.text,
            location: _locationController.text,
            avatarUrl: _avatarUrl,
            coverGradientIndex: _coverGradientIndex,
            coverImageUrl: _coverImageUrl,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 18 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.manage_accounts_rounded,
                    color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Manage Social Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CustomAvatar(
                  imageUrl: _avatarUrl,
                  fallbackName: _nameController.text,
                  radius: 30,
                  hasVipFrame: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : _pickAvatar,
                        icon: const Icon(Icons.camera_alt_rounded, size: 16),
                        label: const Text('Upload Avatar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : _pickCover,
                        icon: const Icon(Icons.wallpaper_rounded, size: 16),
                        label: const Text('Cover Photo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Cover Theme:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 10),
                ...List.generate(kProfileCoverGradients.length, (i) {
                  final selected = i == _coverGradientIndex;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _coverGradientIndex = i;
                      _coverImageUrl = null;
                    }),
                    child: Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            LinearGradient(colors: kProfileCoverGradients[i]),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentOrange
                              : Colors.grey.shade300,
                          width: selected ? 2.5 : 1,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            _field(_nameController, 'Display Name', Icons.person_outline_rounded),
            const SizedBox(height: 10),
            _field(_handleController, 'Username Handle (e.g. @player)',
                Icons.alternate_email_rounded),
            const SizedBox(height: 10),
            _field(_bioController, 'Bio / About You', Icons.info_outline_rounded,
                maxLines: 3),
            const SizedBox(height: 10),
            _field(_locationController, 'Location', Icons.location_on_outlined),
            const SizedBox(height: 16),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _uploading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Save Profile Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19, color: AppColors.primaryGreen),
        filled: true,
        fillColor: const Color(0xFFF3F7F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
