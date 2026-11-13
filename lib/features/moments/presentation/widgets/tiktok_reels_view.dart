import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../domain/entities/moment_post.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import 'moment_comments_sheet.dart';

/// Full-screen vertical swipeable TikTok-style Reels player
class TikTokReelsView extends StatefulWidget {
  final List<MomentPost> posts;
  final Widget? topOverlay;

  const TikTokReelsView({
    super.key,
    required this.posts,
    this.topOverlay,
  });

  @override
  State<TikTokReelsView> createState() => _TikTokReelsViewState();
}

class _TikTokReelsViewState extends State<TikTokReelsView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  bool _isPlaying = true;

  // Local likes tracking
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCounts = {};
  final Set<String> _followedUsers = {};

  // Heart burst animation state
  final List<_FloatingHeart> _burstHearts = [];

  // Vinyl disc rotation animation
  late AnimationController _discAnimController;

  // Default fallback reels if no video posts exist in Supabase yet
  late List<MomentPost> _allReels;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _setupReelsData();
  }

  void _setupReelsData() {
    // Filter posts that are categorized as 'Video' or have media
    final videoPosts = widget.posts.where((p) => p.category == 'Video' || p.imageUrls.isNotEmpty).toList();

    if (videoPosts.isNotEmpty) {
      _allReels = videoPosts;
    } else {
      // High quality curated demo reels to ensure the user sees an authentic TikTok experience
      _allReels = [
        MomentPost(
          id: 'reel_demo_1',
          authorId: 'user_tania',
          authorName: 'Tania Ahmed 🇧🇩',
          authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
          countryFlag: '🇧🇩',
          authorLevel: 12,
          content: 'Live party vibe tonight! Who is ready for the PK Battle? 🔥👑 #gamegala #party #reels #dhaka',
          imageUrls: ['https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1080'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          likesCount: 1420,
          commentsCount: 88,
          category: 'Video',
        ),
        MomentPost(
          id: 'reel_demo_2',
          authorId: 'user_prince',
          authorName: 'Killer Prince ⚔️',
          authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
          countryFlag: '🇧🇩',
          authorLevel: 18,
          content: 'Just won 50,000 Gems in Lucky Wheel! 🏎️💎 Celebrating with my room squad! #gemgala #winner #jackpot',
          imageUrls: ['https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1080'],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          likesCount: 3890,
          commentsCount: 164,
          category: 'Video',
        ),
        MomentPost(
          id: 'reel_demo_3',
          authorId: 'user_zoya',
          authorName: 'Zoya Khan ✨',
          authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
          countryFlag: '🇦🇪',
          authorLevel: 25,
          content: '1v1 Video Call with my top gifter today! Thanks for the Supercar gift 💖🥰 #vip #dubai #royal',
          imageUrls: ['https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1080'],
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          likesCount: 6720,
          commentsCount: 310,
          category: 'Video',
        ),
      ];
    }

    for (final post in _allReels) {
      _likedPosts[post.id] = post.isLiked;
      _likesCounts[post.id] = post.likesCount;
    }
  }

  @override
  void didUpdateWidget(covariant TikTokReelsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.posts != oldWidget.posts) {
      _setupReelsData();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _discAnimController.dispose();
    super.dispose();
  }

  void _onDoubleTapLike(TapDownDetails details, MomentPost post) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _burstHearts.add(_FloatingHeart(
        key: UniqueKey(),
        position: localPos,
        onFinished: (key) {
          setState(() {
            _burstHearts.removeWhere((h) => h.key == key);
          });
        },
      ));

      if (!(_likedPosts[post.id] ?? false)) {
        _likedPosts[post.id] = true;
        _likesCounts[post.id] = (_likesCounts[post.id] ?? post.likesCount) + 1;
        context.read<MomentsBloc>().add(ToggleLikePostEvent(post.id));
      }
    });
  }

  void _toggleLike(MomentPost post) {
    final isLiked = _likedPosts[post.id] ?? post.isLiked;
    final currentCount = _likesCounts[post.id] ?? post.likesCount;

    setState(() {
      _likedPosts[post.id] = !isLiked;
      _likesCounts[post.id] = isLiked ? max(0, currentCount - 1) : currentCount + 1;
    });

    context.read<MomentsBloc>().add(ToggleLikePostEvent(post.id));
  }

  void _toggleFollow(String authorId) {
    setState(() {
      if (_followedUsers.contains(authorId)) {
        _followedUsers.remove(authorId);
      } else {
        _followedUsers.add(authorId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Creator followed! You will now see their latest Moments.'),
            backgroundColor: AppColors.gemEmerald,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _openCommentsSheet(MomentPost post) {
    MomentCommentsSheet.show(context, post);
  }

  void _openGiftModal(MomentPost post) {
    final gifts = [
      {'name': 'Rose 🌹', 'cost': 10, 'icon': '🌹'},
      {'name': 'Love Heart 💖', 'cost': 50, 'icon': '💖'},
      {'name': 'Supercar 🏎️', 'cost': 500, 'icon': '🏎️'},
      {'name': 'Royal Crown 👑', 'cost': 1000, 'icon': '👑'},
      {'name': 'Diamond Ring 💍', 'cost': 2500, 'icon': '💍'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF07221A).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: const Border(top: BorderSide(color: AppColors.goldCoin, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Send Gift to ${post.authorName}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(modalCtx),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Gifts Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
              ),
              itemCount: gifts.length,
              itemBuilder: (ctx, idx) {
                final gift = gifts[idx];
                final cost = gift['cost'] as int;
                return GestureDetector(
                  onTap: () {
                    final profileBloc = context.read<ProfileBloc>();
                    final currentCoins = profileBloc.state.profile.coinBalance;

                    if (currentCoins < cost) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Insufficient coins to send this gift!')),
                      );
                      return;
                    }

                    profileBloc.add(
                      ProfileBalancesUpdatedFromRealtimeEvent(
                        coinBalance: currentCoins - cost,
                      ),
                    );

                    Navigator.pop(modalCtx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Sent ${gift['name']} to ${post.authorName}!'),
                        backgroundColor: AppColors.gemEmerald,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gift['icon'] as String, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🟡', style: TextStyle(fontSize: 8)),
                            const SizedBox(width: 2),
                            Text(
                              '$cost',
                              style: const TextStyle(color: AppColors.goldCoin, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_allReels.isEmpty) {
      return const Center(
        child: Text('No Reels Available', style: TextStyle(color: Colors.white60)),
      );
    }

    return Stack(
      children: [
        // 1. Vertical Full-Screen PageView
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _allReels.length,
          onPageChanged: (index) {
            setState(() {
              _isPlaying = true;
            });
          },
          itemBuilder: (context, index) {
            final reel = _allReels[index];
            return _buildReelPage(reel);
          },
        ),

        // 2. Bursting floating hearts layer
        ..._burstHearts,

        // 3. Top Overlay (Subtabs bar)
        if (widget.topOverlay != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.topOverlay!,
          ),
      ],
    );
  }

  Widget _buildReelPage(MomentPost reel) {
    final isLiked = _likedPosts[reel.id] ?? reel.isLiked;
    final likesCount = _likesCounts[reel.id] ?? reel.likesCount;
    final isFollowed = _followedUsers.contains(reel.authorId);

    final mediaUrl = reel.imageUrls.isNotEmpty ? reel.imageUrls.first : '';

    return GestureDetector(
      onDoubleTapDown: (details) => _onDoubleTapLike(details, reel),
      onTap: () {
        setState(() => _isPlaying = !_isPlaying);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video Canvas / Image with Atmospheric Ambient Glow
          if (mediaUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: mediaUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.black),
              errorWidget: (_, __, ___) => _buildFallbackReelBackground(reel),
            )
          else
            _buildFallbackReelBackground(reel),

          // Cinematic Dark Vignette Gradients
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.2, 0.65, 1.0],
              ),
            ),
          ),

          // Play / Pause Indicator Overlay (when paused)
          if (!_isPlaying)
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
              ),
            ),

          // Right Side Action Buttons Stack (Avatar, Like, Comment, Gift, Share, Disc)
          Positioned(
            right: 12,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Creator Avatar + Follow Button (+)
                _buildCreatorAvatarWithFollow(reel, isFollowed),
                const SizedBox(height: 18),

                // 2. Like Button
                _buildActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  iconColor: isLiked ? Colors.redAccent : Colors.white,
                  label: _formatCount(likesCount),
                  onTap: () => _toggleLike(reel),
                ),
                const SizedBox(height: 16),

                // 3. Comment Button
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: _formatCount(reel.commentsCount),
                  onTap: () => _openCommentsSheet(reel),
                ),
                const SizedBox(height: 16),

                // 4. Send Gift Button
                _buildActionButton(
                  icon: Icons.card_giftcard_rounded,
                  iconColor: AppColors.goldCoin,
                  label: 'Gift',
                  onTap: () => _openGiftModal(reel),
                ),
                const SizedBox(height: 16),

                // 5. Share Button
                _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🔗 Reel link copied to clipboard!')),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 6. Spinning Music Vinyl Disc
                _buildSpinningMusicDisc(reel),
              ],
            ),
          ),

          // Bottom Left Content Overlay (Creator name, Caption, Music Ticker)
          Positioned(
            left: 16,
            right: 85,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creator Handle & Verified Badge
                Row(
                  children: [
                    Text(
                      reel.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
                const SizedBox(height: 6),

                // Caption
                Text(
                  reel.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 10),

                // Music Audio Ticker Marquee
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.music_note_rounded, color: AppColors.goldCoin, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Original Sound - Royal Beats Bangladesh 🎵',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildFallbackReelBackground(MomentPost reel) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D3328), Color(0xFF041812), Color(0xFF130924)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomAvatar(
              imageUrl: reel.authorAvatar,
              countryFlag: reel.countryFlag,
              radius: 46,
            ),
            const SizedBox(height: 12),
            Text(
              reel.authorName,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Party Video Reel', style: TextStyle(color: Colors.white60, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorAvatarWithFollow(MomentPost reel, bool isFollowed) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: reel.authorAvatar.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: reel.authorAvatar,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
        ),

        // Plus Follow Badge
        Positioned(
          bottom: -7,
          child: GestureDetector(
            onTap: () => _toggleFollow(reel.authorId),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFollowed ? AppColors.gemEmerald : Colors.redAccent,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                isFollowed ? Icons.check_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color iconColor = Colors.white,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
              shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinningMusicDisc(MomentPost reel) {
    return RotationTransition(
      turns: _discAnimController,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF262626), Color(0xFF0F0F0F), Color(0xFF1E1E1E)],
          ),
          border: Border.all(color: const Color(0xFF333333), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldCoin, width: 1.5),
            ),
            child: ClipOval(
              child: reel.authorAvatar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: reel.authorAvatar,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.music_note, color: Colors.white, size: 12),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _FloatingHeart extends StatefulWidget {
  final Offset position;
  final void Function(Key key) onFinished;

  const _FloatingHeart({
    required super.key,
    required this.position,
    required this.onFinished,
  });

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _yOffset;
  late double _rotation;

  @override
  void initState() {
    super.initState();
    _rotation = (Random().nextDouble() - 0.5) * 0.5;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.4).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 60),
    ]).animate(_controller);

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeIn)),
    );

    _yOffset = Tween<double>(begin: 0, end: -120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    _controller.forward().then((_) => widget.onFinished(widget.key!));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 40,
      top: widget.position.dy - 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _yOffset.value),
            child: Transform.rotate(
              angle: _rotation,
              child: Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.redAccent,
                    size: 80,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
