import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/entities/moment_post.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../pages/social_profile_page.dart';
import 'moment_comments_sheet.dart';
import 'moment_media_image.dart';

/// Reusable interactive community post card shared between the Moments feed
/// and Social Profile tabs.
class MomentPostCard extends StatelessWidget {
  final MomentPost post;

  const MomentPostCard({super.key, required this.post});

  void _openAuthorProfile(BuildContext context) {
    final bloc = context.read<MomentsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SocialProfilePage(
            userId: post.authorId.isEmpty ? null : post.authorId,
            fallbackPost: post,
          ),
        ),
      ),
    );
  }

  void _openShareSheet(BuildContext context) {
    final bloc = context.read<MomentsBloc>();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;
        return BlocProvider.value(
          value: bloc,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 18 + bottomInset),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Share ${post.authorName}\'s Post',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Add a caption when reposting (optional)...',
                    filled: true,
                    fillColor: const Color(0xFFF3F7F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _shareOptionTile(
                  icon: Icons.repeat_rounded,
                  color: AppColors.primaryGreen,
                  title: 'Repost to Community Feed',
                  subtitle: 'Share this post with your followers & profile',
                  onTap: () {
                    bloc.add(
                      SharePostEvent(
                        postId: post.id,
                        target: SharePostTarget.repostFeed,
                        note: noteController.text,
                      ),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                const SizedBox(height: 8),
                _shareOptionTile(
                  icon: Icons.copy_rounded,
                  color: Colors.blueGrey,
                  title: 'Copy Post Link & Text',
                  subtitle: 'Copy text to share anywhere outside the app',
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                          text: '${post.authorName}: ${post.content}'),
                    );
                    bloc.add(
                      SharePostEvent(
                        postId: post.id,
                        target: SharePostTarget.copyLink,
                      ),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shareOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _openImagePreview(BuildContext context, String url) {
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

  @override
  Widget build(BuildContext context) {
    final isMine =
        post.authorId == (AuthSessionManager.currentUserId ?? 'royal_guest');

    return BlocBuilder<MomentsBloc, MomentsState>(
      buildWhen: (prev, curr) =>
          prev.followedAuthorIds != curr.followedAuthorIds ||
          prev.posts != curr.posts,
      builder: (context, state) {
        final isFollowing = state.followedAuthorIds.contains(post.authorId);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.isRepost && post.repostedFromAuthor != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.repeat_rounded,
                          size: 14, color: AppColors.primaryGreen),
                      const SizedBox(width: 5),
                      Text(
                        'Reposted from ${post.repostedFromAuthor}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),

              // Author Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAuthorProfile(context),
                    child: CustomAvatar(
                      imageUrl: post.authorAvatar,
                      fallbackName: post.authorName,
                      radius: 21,
                      countryFlag: post.countryFlag,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openAuthorProfile(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Lv.${post.authorLevel}',
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                DateFormat('MMM d').format(post.createdAt),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              if (post.location != null &&
                                  post.location!.isNotEmpty) ...[
                                const Text(
                                  ' • ',
                                  style:
                                      TextStyle(color: AppColors.textMuted),
                                ),
                                const Icon(Icons.location_on_rounded,
                                    size: 12, color: AppColors.primaryGreen),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    post.location!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isMine && post.authorId.isNotEmpty)
                    GestureDetector(
                      onTap: () => context.read<MomentsBloc>().add(
                            ToggleFollowAuthorEvent(
                              authorId: post.authorId,
                              authorName: post.authorName,
                            ),
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isFollowing
                              ? const Color(0xFFEFF4F0)
                              : AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isFollowing ? 'Following' : '+ Follow',
                          style: TextStyle(
                            color: isFollowing
                                ? AppColors.primaryGreen
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded,
                        color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'profile') {
                        _openAuthorProfile(context);
                      } else if (val == 'share') {
                        _openShareSheet(context);
                      } else if (val == 'delete') {
                        context
                            .read<MomentsBloc>()
                            .add(DeleteMomentEvent(post.id));
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('View Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Share Options'),
                          ],
                        ),
                      ),
                      if (isMine)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Delete Post',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              if (post.content.isNotEmpty)
                Text(
                  post.content,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

              // Media Images Grid / Single Hero Image
              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (post.imageUrls.length == 1)
                  GestureDetector(
                    onTap: () =>
                        _openImagePreview(context, post.imageUrls.first),
                    child: MomentMediaImage(
                      source: post.imageUrls.first,
                      width: double.infinity,
                      height: 195,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.imageUrls
                        .map(
                          (img) => GestureDetector(
                            onTap: () => _openImagePreview(context, img),
                            child: MomentMediaImage(
                              source: img,
                              width: 112,
                              height: 112,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),

              // Love / Comment / Share Action Bar
              Row(
                children: [
                  _actionButton(
                    icon: post.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: post.isLiked ? Colors.red : AppColors.textMuted,
                    label: '${post.likesCount}',
                    onTap: () => context
                        .read<MomentsBloc>()
                        .add(ToggleLikePostEvent(post.id)),
                  ),
                  const SizedBox(width: 24),
                  _actionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.textMuted,
                    label: '${post.commentsCount}',
                    onTap: () => MomentCommentsSheet.show(context, post),
                  ),
                  const SizedBox(width: 24),
                  _actionButton(
                    icon: Icons.share_outlined,
                    color: AppColors.textMuted,
                    label: post.sharesCount > 0 ? '${post.sharesCount}' : 'Share',
                    onTap: () => _openShareSheet(context),
                  ),
                  const Spacer(),
                  if (post.category != 'Moments')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F7F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#${post.category}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
