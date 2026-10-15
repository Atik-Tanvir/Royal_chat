import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/moment_post.dart';
import 'moments_event.dart';
import 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  MomentsBloc()
      : super(
          const MomentsState(
            activeTab: 'Follow',
            posts: [],
          ),
        ) {
    on<LoadMomentsEvent>(_onLoadMoments);

    on<ChangeMomentTabEvent>((event, emit) {
      emit(state.copyWith(activeTab: event.tab));
      add(LoadMomentsEvent());
    });

    on<AddMomentPostEvent>((event, emit) async {
      final user = SupabaseConfig.client.auth.currentUser;
      final authorName = user?.userMetadata?['full_name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          user?.email?.split('@').first ??
          'RoyalUser';
      final authorAvatar = user?.userMetadata?['avatar_url'] as String? ?? '';

      final newPost = MomentPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorName: authorName,
        authorAvatar: authorAvatar,
        countryFlag: '🇧🇩',
        authorLevel: 1,
        content: event.content,
        imageUrls: event.images,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );
      emit(state.copyWith(posts: [newPost, ...state.posts]));
      await _saveToSupabase(newPost);
    });

    on<CreateMomentEvent>((event, emit) async {
      final user = SupabaseConfig.client.auth.currentUser;
      final authorName = user?.userMetadata?['full_name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          user?.email?.split('@').first ??
          'RoyalUser';
      final authorAvatar = user?.userMetadata?['avatar_url'] as String? ?? '';

      final newPost = MomentPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorName: authorName,
        authorAvatar: authorAvatar,
        countryFlag: '🇧🇩',
        authorLevel: 1,
        content: event.content,
        imageUrls: event.imageUrls,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );
      emit(state.copyWith(posts: [newPost, ...state.posts]));
      await _saveToSupabase(newPost);
    });

    on<ToggleLikePostEvent>((event, emit) async {
      final updatedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          final isLiked = !post.isLiked;
          final newCount = isLiked ? post.likesCount + 1 : post.likesCount - 1;
          _updateLikesInSupabase(post.id, newCount);
          return post.copyWith(
            isLiked: isLiked,
            likesCount: newCount,
          );
        }
        return post;
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    });

    // Initial dynamic load from Supabase
    add(LoadMomentsEvent());
  }

  Future<void> _onLoadMoments(LoadMomentsEvent event, Emitter<MomentsState> emit) async {
    try {
      final response = state.activeTab == 'Hot'
          ? await SupabaseConfig.client
              .from('moments')
              .select()
              .order('likes_count', ascending: false)
          : await SupabaseConfig.client
              .from('moments')
              .select()
              .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final dynamicPosts = (response as List).map((row) {
          List<String> images = [];
          final rawImages = row['image_urls'];
          if (rawImages is List) {
            images = rawImages.map((e) => e.toString()).toList();
          }

          return MomentPost(
            id: row['id'] as String,
            authorName: row['user_name'] as String? ?? 'User',
            authorAvatar: row['user_avatar'] as String? ?? '',
            countryFlag: '🇧🇩',
            authorLevel: 1,
            content: row['content'] as String? ?? '',
            imageUrls: images,
            createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
            likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
            commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
          );
        }).toList();

        emit(state.copyWith(posts: dynamicPosts));
      }
    } catch (e) {
      debugPrint('MomentsBloc Supabase load error: $e');
    }
  }

  Future<void> _saveToSupabase(MomentPost post) async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      await SupabaseConfig.client.from('moments').insert({
        'id': post.id,
        'user_id': user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'user_name': post.authorName,
        'user_avatar': post.authorAvatar,
        'content': post.content,
        'image_urls': post.imageUrls,
        'likes_count': post.likesCount,
        'comments_count': post.commentsCount,
        'category': state.activeTab,
      });
    } catch (e) {
      debugPrint('MomentsBloc Supabase insert error: $e');
    }
  }

  Future<void> _updateLikesInSupabase(String postId, int newCount) async {
    try {
      await SupabaseConfig.client.from('moments').update({
        'likes_count': newCount,
      }).eq('id', postId);
    } catch (e) {
      debugPrint('MomentsBloc Supabase update likes error: $e');
    }
  }
}
