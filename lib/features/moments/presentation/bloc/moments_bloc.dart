import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/moment_post.dart';
import 'moments_event.dart';
import 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  MomentsBloc()
      : super(
          MomentsState(
            activeTab: 'Follow',
            posts: [
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
            ],
          ),
        ) {
    on<ChangeMomentTabEvent>((event, emit) {
      emit(state.copyWith(activeTab: event.tab));
    });

    on<AddMomentPostEvent>((event, emit) {
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
    });

    on<CreateMomentEvent>((event, emit) {
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
    });

    on<ToggleLikePostEvent>((event, emit) {
      final updatedPosts = state.posts.map((post) {
        if (post.id == event.postId) {
          final isLiked = !post.isLiked;
          return post.copyWith(
            isLiked: isLiked,
            likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
          );
        }
        return post;
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    });
  }
}
