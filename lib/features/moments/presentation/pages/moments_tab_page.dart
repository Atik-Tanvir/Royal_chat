import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cat_mascot_widget.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../../domain/entities/moment_post.dart';
import 'create_moment_page.dart';

class MomentsTabPage extends StatelessWidget {
  const MomentsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: Stack(
        children: [
          Column(
            children: [
              // Top Bar: Follow | Moments | Video + Mail Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildSubTabs(context),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.mail_rounded, color: AppColors.goldCoin),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: BlocBuilder<MomentsBloc, MomentsState>(
                  builder: (context, state) {
                    final bool showEmpty = state.activeTab != 'Moments' || state.posts.isEmpty;

                    if (showEmpty) {
                      // Matching Screenshot 2: Empty state with Cat Mascot
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CatMascotWidget(size: 96, withHat: false),
                            const SizedBox(height: 16),
                            Text(
                              'No Moment',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      );
                    }

                    // Rich Moments Feed (Matching Screenshot 5)
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: state.posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final post = state.posts[i];
                        return _buildMomentCard(context, post);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Action Button matching Screenshot 2/3/8: Orange circle with paper plane icon
          Positioned(
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<MomentsBloc>(),
                      child: const CreateMomentPage(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.accentOrangeLight, AppColors.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.near_me_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabs(BuildContext context) {
    return BlocBuilder<MomentsBloc, MomentsState>(
      builder: (context, state) {
        final tabs = ['Follow', 'Moments', 'Video'];
        return Row(
          children: tabs.map((tab) {
            final isSelected = state.activeTab == tab;
            return GestureDetector(
              onTap: () => context.read<MomentsBloc>().add(ChangeMomentTabEvent(tab)),
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  tab,
                  style: isSelected
                      ? AppTextStyles.headerMedium.copyWith(color: Colors.white, fontSize: 18)
                      : AppTextStyles.headerMedium.copyWith(color: Colors.white60, fontSize: 16),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMomentCard(BuildContext context, MomentPost post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                const CustomAvatar(radius: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('5m • ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const Icon(Icons.public, color: Color(0xFF94A3B8), size: 12),
                        const SizedBox(width: 6),
                        Text(post.countryFlag, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
          ),

          // Caption Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              post.content,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2x2 Photo Grid (Screenshot 5)
          if (post.imageUrls.isNotEmpty)
            _buildPhotoGrid(post.imageUrls),

          // Bottom Action Bar: Like & Comment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<MomentsBloc>().add(ToggleLikePostEvent(post.id));
                  },
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                        color: post.isLiked ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          color: post.isLiked ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF64748B), size: 19),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentsCount}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.share_outlined, color: Color(0xFF64748B), size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> images) {
    final count = images.length > 4 ? 4 : images.length;
    final int extraCount = images.length - 4;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, idx) {
              final bool isLastWithMore = idx == 3 && extraCount > 0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    images[idx],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  if (isLastWithMore)
                    Container(
                      color: Colors.black.withOpacity(0.55),
                      alignment: Alignment.center,
                      child: Text(
                        '+$extraCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
