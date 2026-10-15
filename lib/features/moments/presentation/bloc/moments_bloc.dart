import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/moment_comment.dart';
import '../../domain/entities/moment_post.dart';
import 'moments_event.dart';
import 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  static const String _keyLikedPosts = 'royal_liked_moments';
  static const String _keyCommentsPrefix = 'royal_comments_';
  RealtimeChannel? _momentsChannel;

  MomentsBloc() : super(const MomentsState()) {
    on<LoadMomentsEvent>(_onLoadMoments);
    on<ChangeMomentTabEvent>(_onChangeTab);
    on<CreateMomentEvent>(_onCreateMoment);
    on<ToggleLikePostEvent>(_onToggleLike);
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<MomentsUpdatedFromRealtimeEvent>(_onRealtimeUpdate);
    on<LikedPostsLoadedEvent>((event, emit) {
      emit(state.copyWith(likedPostIds: event.likedPostIds));
    });

    _init();
  }

  Future<void> _init() async {
    await _loadLikedPosts();
    _subscribeRealtime();
    add(LoadMomentsEvent());
  }

  void _subscribeRealtime() {
    try {
      _momentsChannel = SupabaseConfig.client
          .channel('public:moments')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'moments',
            callback: (payload) {
              if (payload.newRecord.isNotEmpty) {
                add(MomentsUpdatedFromRealtimeEvent(payload.newRecord));
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[MomentsBloc] Realtime subscription error: $e');
    }
  }

  Future<void> _loadLikedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedList = prefs.getStringList(_keyLikedPosts) ?? [];
      add(LikedPostsLoadedEvent(likedList.toSet()));
    } catch (e) {
      debugPrint('[MomentsBloc] Error loading liked posts: $e');
    }
  }

  Future<void> _saveLikedPosts(Set<String> liked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyLikedPosts, liked.toList());
    } catch (e) {
      debugPrint('[MomentsBloc] Error saving liked posts: $e');
    }
  }

  void _onChangeTab(ChangeMomentTabEvent event, Emitter<MomentsState> emit) {
    emit(state.copyWith(activeTab: event.tab));
    add(LoadMomentsEvent());
  }

  Future<void> _onLoadMoments(LoadMomentsEvent event, Emitter<MomentsState> emit) async {
    if (state.posts.isEmpty) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      // Dynamic queries based on selected tab:
      // - 'Follow' / 'Hot': sorted by highest likes
      // - 'Moments': sorted by latest created_at
      // - 'Video': latest moments with video or media content
      final dynamic response;
      if (state.activeTab == 'Follow') {
        response = await SupabaseConfig.client
            .from('moments')
            .select()
            .order('likes_count', ascending: false);
      } else {
        response = await SupabaseConfig.client
            .from('moments')
            .select()
            .order('created_at', ascending: false);
      }

      final dynamicPosts = (response as List).map((row) {
        List<String> images = [];
        final rawImages = row['image_urls'];
        if (rawImages is List) {
          images = rawImages.map((e) => e.toString()).toList();
        }

        final postId = row['id'] as String;
        final isLiked = state.likedPostIds.contains(postId);

        return MomentPost(
          id: postId,
          authorId: row['user_id'] as String? ?? '',
          authorName: row['user_name'] as String? ?? 'Royal User',
          authorAvatar: row['user_avatar'] as String? ?? '',
          countryFlag: '🇧🇩',
          authorLevel: 1,
          content: row['content'] as String? ?? '',
          imageUrls: images,
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
          commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
          isLiked: isLiked,
          category: row['category'] as String? ?? 'Moments',
          location: row['location'] as String?,
        );
      }).toList();

      emit(state.copyWith(posts: dynamicPosts, isLoading: false));
    } catch (e) {
      debugPrint('[MomentsBloc] Supabase load error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onCreateMoment(CreateMomentEvent event, Emitter<MomentsState> emit) async {
    final currentUserId = AuthSessionManager.currentUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    
    // Fetch live profile details for authentic display
    String authorName = 'Royal User';
    String authorAvatar = '';
    String countryFlag = '🇧🇩';

    try {
      final profileRes = await SupabaseConfig.client
          .from('profiles')
          .select('nickname, avatar_url, country_flag')
          .eq('id', currentUserId)
          .maybeSingle();

      if (profileRes != null) {
        authorName = profileRes['nickname'] as String? ?? 'Royal User';
        authorAvatar = profileRes['avatar_url'] as String? ?? '';
        countryFlag = profileRes['country_flag'] as String? ?? '🇧🇩';
      }
    } catch (e) {
      debugPrint('[MomentsBloc] Fetch author profile error: $e');
    }

    final postId = 'moment_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final newPost = MomentPost(
      id: postId,
      authorId: currentUserId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      countryFlag: countryFlag,
      authorLevel: 1,
      content: event.content,
      imageUrls: event.imageUrls,
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      category: event.category,
      location: event.location,
    );

    // Optimistically add to state
    emit(state.copyWith(posts: [newPost, ...state.posts]));

    // Persist to Supabase moments table
    try {
      await SupabaseConfig.client.from('moments').insert({
        'id': postId,
        'user_id': currentUserId,
        'user_name': authorName,
        'user_avatar': authorAvatar,
        'content': event.content,
        'image_urls': event.imageUrls,
        'likes_count': 0,
        'comments_count': 0,
        'category': event.category,
        'location': event.location,
      });
      debugPrint('[MomentsBloc] Moment inserted to Supabase: $postId');
    } catch (e) {
      debugPrint('[MomentsBloc] Moment insert error: $e');
    }
  }

  Future<void> _onToggleLike(ToggleLikePostEvent event, Emitter<MomentsState> emit) async {
    final currentlyLiked = state.likedPostIds.contains(event.postId);
    final updatedLiked = Set<String>.from(state.likedPostIds);

    if (currentlyLiked) {
      updatedLiked.remove(event.postId);
    } else {
      updatedLiked.add(event.postId);
    }

    int targetCount = 0;
    final updatedPosts = state.posts.map((post) {
      if (post.id == event.postId) {
        final newLiked = !currentlyLiked;
        final newCount = newLiked ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);
        targetCount = newCount;
        return post.copyWith(isLiked: newLiked, likesCount: newCount);
      }
      return post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts, likedPostIds: updatedLiked));
    _saveLikedPosts(updatedLiked);

    try {
      await SupabaseConfig.client
          .from('moments')
          .update({'likes_count': targetCount})
          .eq('id', event.postId);
    } catch (e) {
      debugPrint('[MomentsBloc] Supabase update likes error: $e');
    }
  }

  Future<void> _onLoadComments(LoadCommentsEvent event, Emitter<MomentsState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList('$_keyCommentsPrefix${event.postId}') ?? [];
      final comments = rawList.map((str) {
        final Map<String, dynamic> json = jsonDecode(str);
        return MomentComment.fromJson(json);
      }).toList();

      final updatedMap = Map<String, List<MomentComment>>.from(state.commentsByPostId);
      updatedMap[event.postId] = comments;
      emit(state.copyWith(commentsByPostId: updatedMap));
    } catch (e) {
      debugPrint('[MomentsBloc] Error loading comments: $e');
    }
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<MomentsState> emit) async {
    final currentUserId = AuthSessionManager.currentUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

    String authorName = 'Royal User';
    String authorAvatar = '';

    try {
      final profileRes = await SupabaseConfig.client
          .from('profiles')
          .select('nickname, avatar_url')
          .eq('id', currentUserId)
          .maybeSingle();

      if (profileRes != null) {
        authorName = profileRes['nickname'] as String? ?? 'Royal User';
        authorAvatar = profileRes['avatar_url'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('[MomentsBloc] Comment author profile fetch error: $e');
    }

    final newComment = MomentComment(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      postId: event.postId,
      userId: currentUserId,
      userName: authorName,
      userAvatar: authorAvatar,
      text: event.text,
      createdAt: DateTime.now(),
    );

    // Update in-memory comments
    final updatedMap = Map<String, List<MomentComment>>.from(state.commentsByPostId);
    final currentComments = List<MomentComment>.from(updatedMap[event.postId] ?? []);
    currentComments.add(newComment);
    updatedMap[event.postId] = currentComments;

    // Increment post's comment count in state
    int newCount = 1;
    final updatedPosts = state.posts.map((p) {
      if (p.id == event.postId) {
        newCount = p.commentsCount + 1;
        return p.copyWith(commentsCount: newCount);
      }
      return p;
    }).toList();

    emit(state.copyWith(commentsByPostId: updatedMap, posts: updatedPosts));

    // Save comments to persistent local cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final strList = currentComments.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList('$_keyCommentsPrefix${event.postId}', strList);
    } catch (e) {
      debugPrint('[MomentsBloc] Save comments cache error: $e');
    }

    // Update Supabase comments count
    try {
      await SupabaseConfig.client
          .from('moments')
          .update({'comments_count': newCount})
          .eq('id', event.postId);
    } catch (e) {
      debugPrint('[MomentsBloc] Update Supabase comments count error: $e');
    }
  }

  void _onRealtimeUpdate(MomentsUpdatedFromRealtimeEvent event, Emitter<MomentsState> emit) {
    try {
      final record = event.payload;
      final updatedId = record['id'] as String?;
      if (updatedId == null) return;

      final existingIndex = state.posts.indexWhere((p) => p.id == updatedId);
      if (existingIndex != -1) {
        final existing = state.posts[existingIndex];
        final updatedPost = existing.copyWith(
          likesCount: (record['likes_count'] as num?)?.toInt() ?? existing.likesCount,
          commentsCount: (record['comments_count'] as num?)?.toInt() ?? existing.commentsCount,
        );
        final newPosts = List<MomentPost>.from(state.posts);
        newPosts[existingIndex] = updatedPost;
        emit(state.copyWith(posts: newPosts));
      } else {
        // New post arrived via Realtime
        List<String> images = [];
        final rawImages = record['image_urls'];
        if (rawImages is List) {
          images = rawImages.map((e) => e.toString()).toList();
        }

        final newPost = MomentPost(
          id: updatedId,
          authorId: record['user_id'] as String? ?? '',
          authorName: record['user_name'] as String? ?? 'Royal User',
          authorAvatar: record['user_avatar'] as String? ?? '',
          countryFlag: '🇧🇩',
          authorLevel: 1,
          content: record['content'] as String? ?? '',
          imageUrls: images,
          createdAt: DateTime.tryParse(record['created_at']?.toString() ?? '') ?? DateTime.now(),
          likesCount: (record['likes_count'] as num?)?.toInt() ?? 0,
          commentsCount: (record['comments_count'] as num?)?.toInt() ?? 0,
          isLiked: state.likedPostIds.contains(updatedId),
          category: record['category'] as String? ?? 'Moments',
          location: record['location'] as String?,
        );
        emit(state.copyWith(posts: [newPost, ...state.posts]));
      }
    } catch (e) {
      debugPrint('[MomentsBloc] Realtime process error: $e');
    }
  }

  @override
  Future<void> close() {
    _momentsChannel?.unsubscribe();
    return super.close();
  }
}
