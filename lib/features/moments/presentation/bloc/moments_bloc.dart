import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/moment_post.dart';
import 'moments_event.dart';
import 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  MomentsBloc() : super(const MomentsState()) {
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
