import 'package:equatable/equatable.dart';
import '../../domain/entities/moment_comment.dart';
import '../../domain/entities/moment_post.dart';

class MomentsState extends Equatable {
  final String activeTab; // 'Follow', 'Moments', 'Video'
  final List<MomentPost> posts;
  final bool isLoading;
  final Map<String, List<MomentComment>> commentsByPostId;
  final Set<String> likedPostIds;

  const MomentsState({
    this.activeTab = 'Moments',
    this.posts = const [],
    this.isLoading = false,
    this.commentsByPostId = const {},
    this.likedPostIds = const {},
  });

  MomentsState copyWith({
    String? activeTab,
    List<MomentPost>? posts,
    bool? isLoading,
    Map<String, List<MomentComment>>? commentsByPostId,
    Set<String>? likedPostIds,
  }) {
    return MomentsState(
      activeTab: activeTab ?? this.activeTab,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      commentsByPostId: commentsByPostId ?? this.commentsByPostId,
      likedPostIds: likedPostIds ?? this.likedPostIds,
    );
  }

  @override
  List<Object?> get props => [
        activeTab,
        posts,
        isLoading,
        commentsByPostId,
        likedPostIds,
      ];
}
