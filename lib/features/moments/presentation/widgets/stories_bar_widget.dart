import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/entities/moment_story.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_state.dart';
import '../pages/story_viewer_page.dart';
import 'moment_media_image.dart';

/// Horizontal Stories rail shown at the top of the Moments feed.
class StoriesBarWidget extends StatelessWidget {
  const StoriesBarWidget({super.key});

  void _openStoryStack(
    BuildContext context,
    List<MomentStory> stories,
    int initialIndex,
  ) {
    final bloc = context.read<MomentsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: StoryViewerPage(
            stories: stories,
            initialIndex: initialIndex,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentsBloc, MomentsState>(
      builder: (context, state) {
        final stories = state.stories;
        if (stories.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 118,
          margin: const EdgeInsets.only(top: 10, bottom: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              // Community Stories (View-only, no story creation)
              ...List.generate(stories.length, (idx) {
                final story = stories[idx];
                final isViewed = state.viewedStoryIds.contains(story.id);
                return _StoryTile(
                  story: story,
                  isViewed: isViewed,
                  onTap: () => _openStoryStack(context, stories, idx),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _StoryTile extends StatelessWidget {
  final MomentStory story;
  final bool isViewed;
  final VoidCallback onTap;

  const _StoryTile({
    required this.story,
    required this.isViewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient =
        kStoryGradients[story.bgGradientIndex % kStoryGradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isViewed ? Colors.white30 : AppColors.accentOrange,
            width: isViewed ? 1.5 : 2.3,
          ),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (story.mediaUrl != null && story.mediaUrl!.isNotEmpty)
                MomentMediaImage(
                  source: story.mediaUrl!,
                  fit: BoxFit.cover,
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.68),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: CustomAvatar(
                  imageUrl: story.authorAvatar,
                  fallbackName: story.authorName,
                  radius: 14,
                  countryFlag: story.countryFlag,
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Text(
                  story.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
