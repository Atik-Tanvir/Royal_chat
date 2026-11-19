import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/moment_comment.dart';
import '../../domain/entities/moment_post.dart';
import '../../domain/entities/moment_story.dart';
import '../../domain/entities/social_profile.dart';
import '../../domain/repositories/moments_repository.dart';

/// SharedPreferences-first repository with best-effort Supabase sync and curated
/// starter community data so the social feed always renders cleanly offline & online.
class MomentsRepositoryImpl implements MomentsRepository {
  static const String _postsKey = 'gamegala_moments_posts_v2';
  static const String _storiesKey = 'gamegala_moments_stories_v3';
  static const String _likedKey = 'royal_liked_moments';
  static const String _viewedStoriesKey = 'gamegala_viewed_stories_v2';
  static const String _followedKey = 'gamegala_followed_authors_v2';
  static const String _profilesKey = 'gamegala_social_profiles_v2';
  static const String _commentsIndexKey = 'gamegala_moments_comment_ids_v2';
  static const String _commentsPrefix = 'royal_comments_';

  @override
  Future<List<MomentPost>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedIds = await loadLikedPostIds();
    List<MomentPost> localPosts = [];

    final cachedRaw = prefs.getString(_postsKey);
    if (cachedRaw != null && cachedRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedRaw) as List<dynamic>;
        localPosts = decoded
            .map((e) => MomentPost.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    if (localPosts.isEmpty) {
      localPosts = _buildStarterPosts();
      await savePosts(localPosts);
    }

    // Best-effort remote merge if Supabase is reachable.
    try {
      final res = await SupabaseConfig.client
          .from('moments')
          .select()
          .order('created_at', ascending: false)
          .limit(30)
          .timeout(const Duration(seconds: 3));

      final remoteList = (res as List<dynamic>).map((row) {
        final m = Map<String, dynamic>.from(row);
        final postId = m['id']?.toString() ?? '';
        final rawLikes = (m['likes_count'] as num?)?.toInt() ?? 0;
        return MomentPost(
          id: postId,
          authorId: m['author_id']?.toString() ?? '',
          authorName: m['author_name']?.toString() ?? 'Player',
          authorAvatar: m['author_avatar']?.toString() ??
              'royal_avatar://${_initialsFor(m['author_name']?.toString() ?? 'PL')}:1F7A52',
          countryFlag: m['country_flag']?.toString() ?? '🇧🇩',
          authorLevel: (m['author_level'] as num?)?.toInt() ?? 10,
          content: m['content']?.toString() ?? '',
          imageUrls: List<String>.from(m['image_urls'] ?? const []),
          createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
              DateTime.now(),
          likesCount: rawLikes,
          commentsCount: (m['comments_count'] as num?)?.toInt() ?? 0,
          sharesCount: (m['shares_count'] as num?)?.toInt() ?? 0,
          isLiked: likedIds.contains(postId),
          category: m['category']?.toString() ?? 'Moments',
          location: m['location']?.toString(),
        );
      }).toList();

      if (remoteList.isNotEmpty) {
        final existingById = {for (final p in localPosts) p.id: p};
        for (final remote in remoteList) {
          existingById.putIfAbsent(remote.id, () => remote);
        }
        localPosts = existingById.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {
      // Offline / DNS unreachable: keep local cached + starter posts cleanly.
    }

    return localPosts
        .map((p) => p.copyWith(isLiked: likedIds.contains(p.id)))
        .toList();
  }

  @override
  Future<void> savePosts(List<MomentPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _postsKey,
      jsonEncode(posts.map((p) => p.toJson()).toList()),
    );
  }

  @override
  Future<void> publishPostToRemote(MomentPost post) async {
    try {
      await SupabaseConfig.client.from('moments').insert({
        'author_id': post.authorId,
        'author_name': post.authorName,
        'author_avatar': post.authorAvatar,
        'country_flag': post.countryFlag,
        'author_level': post.authorLevel,
        'content': post.content,
        'image_urls': post.imageUrls,
        'category': post.category,
        'location': post.location,
        'likes_count': post.likesCount,
        'comments_count': post.commentsCount,
      }).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  @override
  Future<void> toggleLikeRemote(String postId, int nextLikesCount) async {
    try {
      await SupabaseConfig.client
          .from('moments')
          .update({'likes_count': nextLikesCount})
          .eq('id', postId)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  @override
  Future<List<MomentStory>> loadStories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storiesKey);
    List<MomentStory> stories = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        stories = decoded
            .map((e) => MomentStory.fromJson(Map<String, dynamic>.from(e)))
            .where((s) => !s.isExpired)
            .toList();
      } catch (_) {}
    }

    if (stories.isEmpty) {
      stories = _buildStarterStories();
      await saveStories(stories);
    }
    return stories;
  }

  @override
  Future<void> saveStories(List<MomentStory> stories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storiesKey,
      jsonEncode(stories.map((s) => s.toJson()).toList()),
    );
  }

  @override
  Future<Map<String, List<MomentComment>>> loadAllComments() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, List<MomentComment>>{};
    final indexedIds = prefs.getStringList(_commentsIndexKey) ?? [];
    final allIds = {...indexedIds, 'starter_yanboyy', 'starter_arafat', 'starter_sadia'};

    for (final postId in allIds) {
      final rawList = prefs.getStringList('$_commentsPrefix$postId');
      if (rawList != null && rawList.isNotEmpty) {
        map[postId] = rawList
            .map((item) => MomentComment.fromJson(jsonDecode(item)))
            .toList();
      }
    }

    // Seed starter comments once if missing so posts feel alive immediately.
    if (!map.containsKey('starter_yanboyy')) {
      final starter = [
        MomentComment(
          id: 'c_yan_1',
          postId: 'starter_yanboyy',
          userId: 'user_sadia',
          userName: 'SadiaQueen',
          userAvatar: 'royal_avatar://SQ:8E24AA',
          text: 'Congratulations bro! 250K jackpot is massive!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MomentComment(
          id: 'c_yan_2',
          postId: 'starter_yanboyy',
          userId: 'user_arafat',
          userName: 'Arafat_BD',
          userAvatar: 'royal_avatar://AB:00897B',
          text: 'Save some luck for tonight party room!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
        ),
      ];
      map['starter_yanboyy'] = starter;
      await saveCommentsForPost('starter_yanboyy', starter);
    }

    return map;
  }

  @override
  Future<void> saveCommentsForPost(
      String postId, List<MomentComment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = comments.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList('$_commentsPrefix$postId', encoded);

    final indexed = (prefs.getStringList(_commentsIndexKey) ?? []).toSet();
    if (indexed.add(postId)) {
      await prefs.setStringList(_commentsIndexKey, indexed.toList());
    }
  }

  @override
  Future<Set<String>> loadLikedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_likedKey) ?? const []).toSet();
  }

  @override
  Future<void> saveLikedPostIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_likedKey, ids.toList());
  }

  @override
  Future<Set<String>> loadViewedStoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_viewedStoriesKey) ?? const []).toSet();
  }

  @override
  Future<void> saveViewedStoryIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_viewedStoriesKey, ids.toList());
  }

  @override
  Future<Set<String>> loadFollowedAuthorIds() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_followedKey);
    if (saved == null) {
      final defaults = {'user_yanboyy', 'user_sadia'};
      await prefs.setStringList(_followedKey, defaults.toList());
      return defaults;
    }
    return saved.toSet();
  }

  @override
  Future<void> saveFollowedAuthorIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_followedKey, ids.toList());
  }

  @override
  Future<Map<String, SocialProfileDetails>> loadSocialProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    final profiles = <String, SocialProfileDetails>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          profiles[entry.key] = SocialProfileDetails.fromJson(
            Map<String, dynamic>.from(entry.value),
          );
        }
      } catch (_) {}
    }

    for (final entry in _starterProfiles().entries) {
      profiles.putIfAbsent(entry.key, () => entry.value);
    }

    await saveSocialProfiles(profiles);
    return profiles;
  }

  @override
  Future<void> saveSocialProfiles(
      Map<String, SocialProfileDetails> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      for (final entry in profiles.entries) entry.key: entry.value.toJson(),
    };
    await prefs.setString(_profilesKey, jsonEncode(map));
  }

  static String _initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'PL';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  List<MomentPost> _buildStarterPosts() {
    final now = DateTime.now();
    return [
      MomentPost(
        id: 'starter_yanboyy',
        authorId: 'user_yanboyy',
        authorName: 'yanboyy',
        authorAvatar: 'royal_avatar://YB:E65100',
        countryFlag: '🇧🇩',
        authorLevel: 24,
        content:
            'Just won 250,000 coins on the Lucky Wheel! 🔥 Luck is definitely on my side today!',
        imageUrls: const ['royal_art://lucky_wheel'],
        createdAt: now.subtract(const Duration(hours: 3)),
        likesCount: 215,
        commentsCount: 2,
        sharesCount: 18,
        category: 'Moments',
        location: 'Chittagong',
      ),
      MomentPost(
        id: 'starter_sadia',
        authorId: 'user_sadia',
        authorName: 'SadiaQueen',
        authorAvatar: 'royal_avatar://SQ:8E24AA',
        countryFlag: '🇧🇩',
        authorLevel: 31,
        content:
            'Hosting Golden Mic Voice Party tonight at 9 PM! Drop by for PK battles and coin rain 🎤✨',
        imageUrls: const ['royal_art://party_stage'],
        createdAt: now.subtract(const Duration(hours: 6)),
        likesCount: 148,
        commentsCount: 0,
        sharesCount: 9,
        category: 'Moments',
        location: 'Dhaka',
      ),
      MomentPost(
        id: 'starter_arafat',
        authorId: 'user_arafat',
        authorName: 'Arafat_BD',
        authorAvatar: 'royal_avatar://AB:00897B',
        countryFlag: '🇧🇩',
        authorLevel: 19,
        content:
            'Evening chai & Balloon Sky high score run! Who can beat 42 seconds on fast speed mode? 🎈🚀',
        imageUrls: const ['royal_art://balloon_sky'],
        createdAt: now.subtract(const Duration(hours: 11)),
        likesCount: 96,
        commentsCount: 0,
        sharesCount: 7,
        category: 'Moments',
        location: 'Sylhet',
      ),
      MomentPost(
        id: 'starter_farhan',
        authorId: 'user_farhan',
        authorName: 'FarhanPK',
        authorAvatar: 'royal_avatar://FP:C2185B',
        countryFlag: '🇧🇩',
        authorLevel: 28,
        content:
            'Clean sweep in Color Spin Royale! Red & Gold hit back-to-back in group room 👑💛',
        imageUrls: const ['royal_art://pk_trophy'],
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        likesCount: 183,
        commentsCount: 0,
        sharesCount: 14,
        category: 'Moments',
        location: 'Dhaka',
      ),
    ];
  }

  List<MomentStory> _buildStarterStories() {
    final now = DateTime.now();
    return [
      MomentStory(
        id: 'story_yanboyy_1',
        authorId: 'user_yanboyy',
        authorName: 'yanboyy',
        authorAvatar: 'royal_avatar://YB:E65100',
        countryFlag: '🇧🇩',
        mediaUrl: 'royal_art://lucky_wheel',
        caption: '250K coin Lucky Wheel streak! Spin with us today 🎯',
        bgGradientIndex: 1,
        roomId: 'room_yanboyy_lucky',
        roomTitle: '250K Coin Lucky Room',
        roomCategory: 'Lucky Number',
        roomOnlineCount: 38,
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(hours: 22)),
        viewsCount: 64,
        likesCount: 29,
      ),
      MomentStory(
        id: 'story_sadia_1',
        authorId: 'user_sadia',
        authorName: 'SadiaQueen',
        authorAvatar: 'royal_avatar://SQ:8E24AA',
        countryFlag: '🇧🇩',
        mediaUrl: 'royal_art://party_stage',
        caption: 'Golden Mic Acoustic Room live soon — join stage!',
        bgGradientIndex: 2,
        roomId: 'room_sadia_mic',
        roomTitle: 'Golden Mic Acoustic Stage',
        roomCategory: 'Chatroom',
        roomOnlineCount: 75,
        createdAt: now.subtract(const Duration(hours: 4)),
        expiresAt: now.add(const Duration(hours: 20)),
        viewsCount: 112,
        likesCount: 51,
      ),
      MomentStory(
        id: 'story_arafat_1',
        authorId: 'user_arafat',
        authorName: 'Arafat_BD',
        authorAvatar: 'royal_avatar://AB:00897B',
        countryFlag: '🇧🇩',
        mediaUrl: null,
        caption: 'Good evening Dhaka! Looking for 7 Up 7 Down squadmates ☕🎲',
        bgGradientIndex: 0,
        roomId: 'room_arafat_squad',
        roomTitle: '7 Up 7 Down Squad Room',
        roomCategory: 'PK',
        roomOnlineCount: 19,
        createdAt: now.subtract(const Duration(hours: 5)),
        expiresAt: now.add(const Duration(hours: 19)),
        viewsCount: 41,
        likesCount: 17,
      ),
    ];
  }

  Map<String, SocialProfileDetails> _starterProfiles() {
    return {
      'user_yanboyy': const SocialProfileDetails(
        userId: 'user_yanboyy',
        usernameHandle: '@yanboyy_ctg',
        nickname: 'yanboyy',
        avatarUrl: 'royal_avatar://YB:E65100',
        coverGradientIndex: 1,
        bio: 'Lucky Wheel hunter • Chittagong vibes • Always up for group Color Spin!',
        location: 'Chittagong, Bangladesh',
        countryFlag: '🇧🇩',
        level: 24,
        joinedLabel: 'Member since Jan 2025',
        followersCount: 642,
        followingCount: 95,
      ),
      'user_sadia': const SocialProfileDetails(
        userId: 'user_sadia',
        usernameHandle: '@sadia_queen',
        nickname: 'SadiaQueen',
        avatarUrl: 'royal_avatar://SQ:8E24AA',
        coverGradientIndex: 2,
        bio: 'Voice Party host 🎤 Music, PK nights, and daily coin giveaways!',
        location: 'Dhaka, Bangladesh',
        countryFlag: '🇧🇩',
        level: 31,
        joinedLabel: 'Member since Nov 2024',
        followersCount: 1240,
        followingCount: 132,
      ),
      'user_arafat': const SocialProfileDetails(
        userId: 'user_arafat',
        usernameHandle: '@arafat_bd',
        nickname: 'Arafat_BD',
        avatarUrl: 'royal_avatar://AB:00897B',
        coverGradientIndex: 0,
        bio: 'Balloon Sky top pilot 🎈 & evening chai enthusiast.',
        location: 'Sylhet, Bangladesh',
        countryFlag: '🇧🇩',
        level: 19,
        joinedLabel: 'Member since Feb 2025',
        followersCount: 318,
        followingCount: 88,
      ),
      'user_farhan': const SocialProfileDetails(
        userId: 'user_farhan',
        usernameHandle: '@farhan_pk',
        nickname: 'FarhanPK',
        avatarUrl: 'royal_avatar://FP:C2185B',
        coverGradientIndex: 3,
        bio: 'PK Arena regular 👑 Love competing in Color Spin & Bucket Spin.',
        location: 'Dhaka, Bangladesh',
        countryFlag: '🇧🇩',
        level: 28,
        joinedLabel: 'Member since Dec 2024',
        followersCount: 890,
        followingCount: 110,
      ),
    };
  }
}
