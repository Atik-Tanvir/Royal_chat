import 'package:equatable/equatable.dart';
import '../../domain/entities/moment_post.dart';

class MomentsState extends Equatable {
  final String activeTab; // 'Follow', 'Moments', 'Video'
  final List<MomentPost> posts;
  final bool isLoading;

  const MomentsState({
    this.activeTab = 'Follow', // In Screenshot 3, "Follow" is selected with "No Moment"
    this.posts = const [],
    this.isLoading = false,
  });

  MomentsState copyWith({
    String? activeTab,
    List<MomentPost>? posts,
    bool? isLoading,
  }) {
    return MomentsState(
      activeTab: activeTab ?? this.activeTab,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [activeTab, posts, isLoading];
}
