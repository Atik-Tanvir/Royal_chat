import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/moment_post.dart';
import 'moments_event.dart';
import 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  MomentsBloc()
      : super(
          MomentsState(
            activeTab: 'Follow',
            posts: _getFallbackPosts(),
          ),
        ) {
    on<LoadMomentsEvent>(_onLoadMoments);

    on<ChangeMomentTabEvent>((event, emit) {
      emit(state.copyWith(activeTab: event.tab));
      add(LoadMomentsEvent());
    });

    on<AddMomentPostEvent>((event, emit) async {
      final newPost = MomentPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorName: 'User30961573',
        authorAvatar: '',
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
      final newPost = MomentPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorName: 'User30961573',
        authorAvatar: '',
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

    // Initial load from Supabase
    add(LoadMomentsEvent());
  }

  Future<void> _onLoadMoments(LoadMomentsEvent event, Emitter<MomentsState> emit) async {
    try {
      final response = await SupabaseConfig.client
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

        emit(state.copyWith(posts: [...dynamicPosts, ..._getFallbackPosts()]));
      }
    } catch (e) {
      debugPrint('MomentsBloc Supabase load error: $e');
    }
  }

  Future<void> _saveToSupabase(MomentPost post) async {
    try {
      await SupabaseConfig.client.from('moments').insert({
        'id': post.id,
        'user_id': '30961573',
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

  static List<MomentPost> _getFallbackPosts() {
    return [
      MomentPost(
        id: 'post_kanchanjangha',
        authorName: 'Mahbub Shihab',
        authorAvatar: '',
        countryFlag: '🇧🇩',
        authorLevel: 3,
        content: 'Kanchanjangha view From Tetulia ❤️\nMashaAllah ❤️🎀',
        imageUrls: const [
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500',
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=500',
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500',
          'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?w=500',
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500',
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        likesCount: 142,
        commentsCount: 28,
      ),
    ];
  }
}
