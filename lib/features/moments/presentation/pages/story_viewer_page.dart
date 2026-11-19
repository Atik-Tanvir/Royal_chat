import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../party/presentation/pages/live_audio_room_page.dart';
import '../../domain/entities/moment_story.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../bloc/moments_state.dart';
import '../widgets/moment_media_image.dart';

/// Full-screen interactive Story Viewer with progress segments, Love reaction,
/// view counter, and own-story deletion.
class StoryViewerPage extends StatefulWidget {
  final List<MomentStory> stories;
  final int initialIndex;

  const StoryViewerPage({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _markViewed());
  }

  void _markViewed() {
    if (_currentIndex < 0 || _currentIndex >= widget.stories.length) return;
    context
        .read<MomentsBloc>()
        .add(MarkStoryViewedEvent(widget.stories[_currentIndex].id));
  }

  void _nextStory(List<MomentStory> currentList) {
    if (_currentIndex < currentList.length - 1) {
      setState(() => _currentIndex++);
      _markViewed();
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _markViewed();
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '1d ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentsBloc, MomentsState>(
      builder: (context, state) {
        final activeIds = widget.stories.map((s) => s.id).toSet();
        final liveList = state.stories
            .where((s) => activeIds.contains(s.id))
            .toList();

        if (liveList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const Scaffold(backgroundColor: Colors.black);
        }

        if (_currentIndex >= liveList.length) {
          _currentIndex = liveList.length - 1;
        }
        final story = liveList[_currentIndex];
        final isMine = story.authorId == AuthSessionManager.currentUserId;
        final gradient =
            kStoryGradients[story.bgGradientIndex % kStoryGradients.length];

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient or uploaded photo
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                if (story.mediaUrl != null && story.mediaUrl!.isNotEmpty)
                  MomentMediaImage(
                    source: story.mediaUrl!,
                    fit: BoxFit.contain,
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Tap Left / Right Zones
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _prevStory,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _nextStory(liveList),
                      ),
                    ),
                  ],
                ),

                // Caption overlay
                if (story.caption.isNotEmpty)
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 88,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: story.mediaUrl != null
                            ? Colors.black.withOpacity(0.45)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        story.caption,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: story.mediaUrl == null ? 23 : 16,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),

                // Top Header + Segmented Progress
                Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(liveList.length, (i) {
                          return Expanded(
                            child: Container(
                              height: 3.5,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i <= _currentIndex
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CustomAvatar(
                            imageUrl: story.authorAvatar,
                            fallbackName: story.authorName,
                            radius: 19,
                            countryFlag: story.countryFlag,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.authorName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _timeAgo(story.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMine)
                            IconButton(
                              tooltip: 'Delete Story',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                context
                                    .read<MomentsBloc>()
                                    .add(DeleteStoryEvent(story.id));
                              },
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Join Live Room Banner (when story promotes a room)
                if (story.isRoomStory)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 68,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.goldCoin.withOpacity(0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldCoin.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.goldCoin.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic_external_on_rounded, color: AppColors.goldCoin, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  story.roomTitle ?? 'Popular Live Room',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Text('🔴 LIVE • ', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                    Text(
                                      '${story.roomOnlineCount ?? 1} Listeners',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LiveAudioRoomPage(room: story.toPartyRoom()),
                                ),
                              );
                            },
                            icon: const Icon(Icons.meeting_room_rounded, size: 15, color: Colors.black87),
                            label: const Text('Join Room', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldCoin,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Engagement Bar
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${story.viewsCount} views',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context
                            .read<MomentsBloc>()
                            .add(ToggleLikeStoryEvent(story.id)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: story.isLikedByMe
                                ? Colors.pinkAccent.withOpacity(0.9)
                                : Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                story.isLikedByMe
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${story.likesCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
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
        );
      },
    );
  }
}
