import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../widgets/moment_post_card.dart';
import '../widgets/stories_bar_widget.dart';
import '../widgets/tiktok_reels_view.dart';
import 'create_moment_page.dart';
import 'social_profile_page.dart';

class MomentsTabPage extends StatefulWidget {
  const MomentsTabPage({super.key});

  @override
  State<MomentsTabPage> createState() => _MomentsTabPageState();
}

class _MomentsTabPageState extends State<MomentsTabPage> {
  final TextEditingController _quickStatusController = TextEditingController();

  @override
  void dispose() {
    _quickStatusController.dispose();
    super.dispose();
  }

  void _openMySocialProfile(BuildContext context) {
    final bloc = context.read<MomentsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const SocialProfilePage(),
        ),
      ),
    );
  }

  void _openCreateMoment(BuildContext context) {
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

  void _submitQuickStatus(BuildContext context) {
    final text = _quickStatusController.text.trim();
    if (text.isEmpty) {
      _openCreateMoment(context);
      return;
    }
    context.read<MomentsBloc>().add(
          CreateMomentEvent(
            content: text,
            category: 'Moments',
          ),
        );
    _quickStatusController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showFabActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.add_photo_alternate_rounded,
                      color: AppColors.primaryGreen),
                ),
                title: const Text(
                  'Create Moment Post',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Post photos & text status with your ID (No video)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCreateMoment(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person_pin_rounded,
                      color: AppColors.primaryGreen),
                ),
                title: const Text(
                  'My Social Profile & ID',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Manage bio, avatar, user ID, posts & photos'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openMySocialProfile(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MomentsBloc, MomentsState>(
      listenWhen: (prev, curr) => prev.uiToastTick != curr.uiToastTick,
      listener: (context, state) {
        final msg = state.uiToastMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final activeTab = state.activeTab;
        final isVideoTab = activeTab == 'Video';
        final myProfile = state.mySocialProfile;

        final filteredPosts = activeTab == 'Follow'
            ? state.posts
                .where((p) =>
                    state.followedAuthorIds.contains(p.authorId) ||
                    p.authorId == myProfile?.userId)
                .toList()
            : state.posts;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bgLightGreen, AppColors.bgDarkGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Tab Header + Dedicated "My Profile" button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      children: [
                        _buildTopTab(context, 'Follow', activeTab == 'Follow'),
                        const SizedBox(width: 18),
                        _buildTopTab(context, 'Moments', activeTab == 'Moments'),
                        const SizedBox(width: 18),
                        _buildTopTab(context, 'Video', activeTab == 'Video'),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _openMySocialProfile(context),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 4, 10, 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomAvatar(
                                  imageUrl: myProfile?.avatarUrl ?? '',
                                  fallbackName:
                                      myProfile?.nickname ?? 'My Profile',
                                  radius: 13,
                                  hasVipFrame: true,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'My Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body Content
                  Expanded(
                    child: isVideoTab
                        ? TikTokReelsView(posts: state.posts)
                        : RefreshIndicator(
                            color: AppColors.primaryGreen,
                            onRefresh: () async {
                              context
                                  .read<MomentsBloc>()
                                  .add(LoadMomentsEvent());
                            },
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 90),
                              children: [
                                // Stories Strip
                                const StoriesBarWidget(),

                                // Inline Status / Photo / Story Composer Strip
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      14, 10, 14, 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _openMySocialProfile(context),
                                              child: CustomAvatar(
                                                imageUrl:
                                                    myProfile?.avatarUrl ?? '',
                                                fallbackName:
                                                    myProfile?.nickname ?? 'Me',
                                                radius: 19,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF3F7F4),
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      _quickStatusController,
                                                  textInputAction:
                                                      TextInputAction.send,
                                                  onSubmitted: (_) =>
                                                      _submitQuickStatus(
                                                          context),
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        'Share your status or mood...',
                                                    hintStyle: TextStyle(
                                                      color: AppColors.textMuted,
                                                      fontSize: 13,
                                                    ),
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              tooltip: 'Post Status',
                                              onPressed: () =>
                                                  _submitQuickStatus(context),
                                              icon: const Icon(
                                                Icons.send_rounded,
                                                color: AppColors.primaryGreen,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Divider(
                                            height: 1,
                                            color: Colors.grey.shade200),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _composerShortcut(
                                              icon: Icons.photo_library_rounded,
                                              color: AppColors.primaryGreen,
                                              label: 'Upload Photo',
                                              onTap: () =>
                                                  _openCreateMoment(context),
                                            ),
                                            _composerShortcut(
                                              icon: Icons.edit_note_rounded,
                                              color: AppColors.goldCoin,
                                              label: 'Write Post',
                                              onTap: () =>
                                                  _openCreateMoment(context),
                                            ),
                                            _composerShortcut(
                                              icon: Icons.person_outline_rounded,
                                              color: Colors.teal,
                                              label: 'My Profile',
                                              onTap: () =>
                                                  _openMySocialProfile(context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (state.isLoading && state.posts.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accentOrange,
                                      ),
                                    ),
                                  )
                                else if (filteredPosts.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(Icons.group_outlined,
                                              color: Colors.white70, size: 42),
                                          SizedBox(height: 8),
                                          Text(
                                            'No posts in Follow feed yet',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Follow creators or switch to Moments to explore.',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Column(
                                      children: filteredPosts
                                          .map((post) =>
                                              MomentPostCard(post: post))
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: isVideoTab
                ? null
                : FloatingActionButton(
                    heroTag: 'moments_fab',
                    onPressed: () => _showFabActions(context),
                    backgroundColor: AppColors.accentOrange,
                    elevation: 6,
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
          ),
        );
      },
    );
  }

  Widget _composerShortcut({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<MomentsBloc>().add(ChangeMomentTabEvent(label)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: isSelected ? 18 : 15,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 22 : 0,
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
