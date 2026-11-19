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
import '../pages/story_viewer_page.dart';
import 'moment_media_image.dart';

/// Horizontal Stories & Popular Rooms rail shown at the top of the Moments feed.
/// Allows room owners to feature their popular live room with an instant "Join Room" link.
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

  void _openFeatureRoomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<MomentsBloc>(),
        child: const _FeatureRoomStorySheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MomentsBloc, MomentsState>(
      builder: (context, state) {
        final stories = state.stories;

        return Container(
          height: 124,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              // 1. Feature Room Tile (Lets users promote popular rooms with Join Room link)
              _FeatureRoomTile(
                onTap: () => _openFeatureRoomSheet(context),
              ),

              // 2. Active Room Stories / Featured Live Rooms
              ...List.generate(stories.length, (idx) {
                final story = stories[idx];
                final isViewed = state.viewedStoryIds.contains(story.id);
                return _StoryTile(
                  story: story,
                  isViewed: isViewed,
                  onTap: () {
                    // If story promotes a room, directly let user join or preview
                    _openStoryStack(context, stories, idx);
                  },
                  onJoinTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveAudioRoomPage(room: story.toPartyRoom()),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Feature/Promote Room Tile at the beginning of the rail.
class _FeatureRoomTile extends StatelessWidget {
  final VoidCallback onTap;

  const _FeatureRoomTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.goldCoin.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldCoin.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_external_on_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.gemEmerald,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Feature Room',
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.goldCoin.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Join Link 🎙️',
                style: TextStyle(
                  color: AppColors.goldCoin,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Popular Room Story Tile matching Screenshot 2.
class _StoryTile extends StatelessWidget {
  final MomentStory story;
  final bool isViewed;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;

  const _StoryTile({
    required this.story,
    required this.isViewed,
    required this.onTap,
    required this.onJoinTap,
  });

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'Lucky Number':
        return Icons.casino_rounded;
      case 'Lucky Race':
        return Icons.sports_motorsports_rounded;
      case 'PK':
        return Icons.sports_kabaddi_rounded;
      case 'Chatroom':
      default:
        return Icons.mic_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient =
        kStoryGradients[story.bgGradientIndex % kStoryGradients.length];
    final isRoom = story.isRoomStory;
    final catIcon = _categoryIcon(story.roomCategory);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isViewed
                ? Colors.white30
                : (isRoom ? AppColors.goldCoin : AppColors.accentOrange),
            width: isViewed ? 1.4 : 2.2,
          ),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            if (!isViewed && isRoom)
              BoxShadow(
                color: gradient.first.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
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

              // Ambient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.20),
                      Colors.black.withOpacity(0.72),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Watermark Room/Category Icon in Center (dice, mic, trophy as in 2nd SS)
              Center(
                child: Opacity(
                  opacity: 0.28,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1.5),
                    ),
                    child: Icon(
                      catIcon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Host Avatar with Flag in Top-Left
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

              // "LIVE" badge in top-right
              if (isRoom)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // Room Title & Host Name at Bottom
              Positioned(
                left: 6,
                right: 6,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.caption.isNotEmpty ? story.caption : story.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                      ),
                    ),
                    Text(
                      story.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // "Join 🎙️" Pill Button at Bottom for 1-click room entry
              Positioned(
                left: 6,
                right: 6,
                bottom: 4,
                child: GestureDetector(
                  onTap: onJoinTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.goldCoin,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Join 🎙️',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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

/// Bottom Sheet that allows any user/host to feature their live room as a story
/// with a 1-click Join link.
class _FeatureRoomStorySheet extends StatefulWidget {
  const _FeatureRoomStorySheet();

  @override
  State<_FeatureRoomStorySheet> createState() => _FeatureRoomStorySheetState();
}

class _FeatureRoomStorySheetState extends State<_FeatureRoomStorySheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  String _selectedCategory = 'Chatroom';
  int _selectedGradient = 1;

  final List<String> _categories = [
    'Chatroom',
    'Lucky Number',
    'Lucky Race',
    'PK',
  ];

  @override
  void initState() {
    super.initState();
    final uid = AuthSessionManager.currentUserId ?? 'user';
    _titleController.text = 'VIP Live Voice Stage';
    _roomIdController.text = 'room_$uid';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final roomId = _roomIdController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room title.')),
      );
      return;
    }

    context.read<MomentsBloc>().add(
          CreateStoryEvent(
            caption: title,
            bgGradientIndex: _selectedGradient,
            roomId: roomId.isNotEmpty ? roomId : 'room_${DateTime.now().millisecondsSinceEpoch}',
            roomTitle: title,
            roomCategory: _selectedCategory,
            roomOnlineCount: 1,
          ),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Your Room Story is now featured with a Join Room link!'),
        backgroundColor: AppColors.gemEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF13231B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldCoin.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_external_on_rounded,
                    color: AppColors.goldCoin,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature Your Popular Room',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Post your live room with a direct Join link',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Room Title',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                hintText: 'e.g. 250K Coin Lucky Streak 🎯',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Room Category',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat == 'Chatroom'
                        ? '🎙️ Chatroom'
                        : cat == 'Lucky Number'
                            ? '🎲 Lucky Number'
                            : cat == 'Lucky Race'
                                ? '🏎️ Lucky Race'
                                : '⚔️ PK Battle',
                    style: TextStyle(
                      color: isSelected ? Colors.black87 : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.goldCoin,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text(
              'Room ID / Join Link',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _roomIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                prefixIcon: const Icon(Icons.link_rounded, color: AppColors.goldCoin),
                hintText: 'e.g. room_12345',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Card Color Theme',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(kStoryGradients.length, (idx) {
                final isSel = _selectedGradient == idx;
                final grad = kStoryGradients[idx];
                return GestureDetector(
                  onTap: () => setState(() => _selectedGradient = idx),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: grad),
                      border: Border.all(
                        color: isSel ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.black87),
                label: const Text(
                  'Feature Room on Feed 🚀',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldCoin,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
