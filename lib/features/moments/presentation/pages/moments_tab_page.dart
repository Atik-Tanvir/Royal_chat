import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cat_mascot_widget.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../widgets/create_moment_sheet.dart';

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
                    if (state.posts.isEmpty) {
                      // Matching Screenshot 3: Empty state with Cat Mascot
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
                            const SizedBox(height: 60), // Optical center balance
                          ],
                        ),
                      );
                    }

                    // Posts list
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final post = state.posts[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primaryGreen,
                                    child: Text(post.countryFlag),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                                      ),
                                      Text(
                                        'Just now',
                                        style: AppTextStyles.caption.copyWith(color: Colors.white38),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.gemEmerald.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'LV.${post.authorLevel}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.gemEmerald),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.content,
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: post.isLiked ? Colors.pinkAccent : Colors.white60,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context.read<MomentsBloc>().add(ToggleLikePostEvent(post.id));
                                    },
                                  ),
                                  Text(
                                    '${post.likesCount}',
                                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.chat_bubble_outline, color: Colors.white60, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post.commentsCount}',
                                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Action Button matching Screenshot 3: Orange circle with paper plane icon
          Positioned(
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => CreateMomentSheet(
                    onPost: (content) {
                      context.read<MomentsBloc>().add(AddMomentPostEvent(content: content));
                    },
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
}
