import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../domain/entities/moment_post.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../widgets/moment_comments_sheet.dart';
import 'create_moment_page.dart';

class MomentsTabPage extends StatelessWidget {
  const MomentsTabPage({super.key});

  static String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No new direct messages.')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: BlocBuilder<MomentsBloc, MomentsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.posts.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.gemEmerald),
                      );
                    }

                    if (state.posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const RoyalBrandLogo(size: 80),
                            const SizedBox(height: 18),
                            Text(
                              'No Royal Moments Yet',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Be the first to share a post with the party!',
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
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
                              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                              label: const Text('Post a Moment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gemEmerald,
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.gemEmerald,
                      onRefresh: () async {
                        context.read<MomentsBloc>().add(LoadMomentsEvent());
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: state.posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final post = state.posts[i];
                          return _buildMomentCard(context, post);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Action Button
          Positioned(
            right: 20,
            bottom: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                debugPrint('[MomentsTabPage] FAB tapped!');
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<MomentsBloc>(),
                      child: const CreateMomentPage(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.accentOrangeLight, AppColors.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withValues(alpha: 0.5),
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
        final tabs = ['Moments', 'Follow', 'Video'];
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
            color: Colors.black.withValues(alpha: 0.12),
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
                CustomAvatar(
                  imageUrl: post.authorAvatar,
                  countryFlag: post.countryFlag,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
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
                          Text(
                            '${_formatTimeAgo(post.createdAt)} • ',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                          if (post.location != null && post.location!.isNotEmpty) ...[
                            const Icon(Icons.location_on_rounded, color: AppColors.gemEmerald, size: 12),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                post.location!,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.public, color: Color(0xFF94A3B8), size: 12),
                            const SizedBox(width: 4),
                            Text(post.countryFlag, style: const TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post options')),
                    );
                  },
                ),
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

          // Photos Grid (Handles R2 CDN URLs and Data URIs)
          if (post.imageUrls.isNotEmpty)
            _buildPhotoGrid(context, post.imageUrls),

          // Bottom Action Bar: Like, Comment, Share
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
                        post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
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
                GestureDetector(
                  onTap: () {
                    MomentCommentsSheet.show(context, post);
                  },
                  child: Row(
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
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: 'Check out this moment on Royal Live: ${post.content}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ Moment copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(Icons.share_outlined, color: Color(0xFF64748B), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, List<String> images) {
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
              final imageSrc = images[idx];

              return GestureDetector(
                onTap: () => _openImagePreview(context, imageSrc),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _renderImage(imageSrc),
                    if (isLastWithMore)
                      Container(
                        color: Colors.black.withValues(alpha: 0.55),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _renderImage(String src) {
    if (src.startsWith('data:image')) {
      try {
        final commaIdx = src.indexOf(',');
        final base64String = commaIdx != -1 ? src.substring(commaIdx + 1) : src;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
        );
      } catch (_) {
        return Container(
          color: const Color(0xFFE2E8F0),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: src,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gemEmerald),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  void _openImagePreview(BuildContext context, String src) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: src.startsWith('data:image')
                    ? Image.memory(base64Decode(src.split(',').last), fit: BoxFit.contain)
                    : CachedNetworkImage(imageUrl: src, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
