import 'package:equatable/equatable.dart';
import '../../domain/entities/moment_comment.dart';
import '../../domain/entities/moment_post.dart';
import '../../domain/entities/moment_story.dart';
import '../../domain/entities/social_profile.dart';

class MomentsState extends Equatable {
  final String activeTab; // 'Follow', 'Moments', 'Video'
  final List<MomentPost> posts;
  final List<MomentStory> stories;
  final bool isLoading;
  final Map<String, List<MomentComment>> commentsByPostId;
  final Set<String> likedPostIds;
  final Set<String> viewedStoryIds;
  final Set<String> followedAuthorIds;
  final SocialProfileDetails? mySocialProfile;
  final Map<String, SocialProfileDetails> profilesById;
  final String? uiToastMessage;
  final int uiToastTick;

  const MomentsState({
    this.activeTab = 'Moments',
    this.posts = const [],
    this.stories = const [],
    this.isLoading = false,
    this.commentsByPostId = const {},
    this.likedPostIds = const {},
    this.viewedStoryIds = const {},
    this.followedAuthorIds = const {},
    this.mySocialProfile,
    this.profilesById = const {},
    this.uiToastMessage,
    this.uiToastTick = 0,
  });

  MomentsState copyWith({
    String? activeTab,
    List<MomentPost>? posts,
    List<MomentStory>? stories,
    bool? isLoading,
    Map<String, List<MomentComment>>? commentsByPostId,
    Set<String>? likedPostIds,
    Set<String>? viewedStoryIds,
    Set<String>? followedAuthorIds,
    SocialProfileDetails? mySocialProfile,
    Map<String, SocialProfileDetails>? profilesById,
    String? uiToastMessage,
    int? uiToastTick,
  }) {
    return MomentsState(
      activeTab: activeTab ?? this.activeTab,
      posts: posts ?? this.posts,
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      commentsByPostId: commentsByPostId ?? this.commentsByPostId,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      viewedStoryIds: viewedStoryIds ?? this.viewedStoryIds,
      followedAuthorIds: followedAuthorIds ?? this.followedAuthorIds,
      mySocialProfile: mySocialProfile ?? this.mySocialProfile,
      profilesById: profilesById ?? this.profilesById,
      uiToastMessage: uiToastMessage ?? this.uiToastMessage,
      uiToastTick: uiToastTick ?? this.uiToastTick,
    );
  }

  @override
  List<Object?> get props => [
        activeTab,
        posts,
        stories,
        isLoading,
        commentsByPostId,
        likedPostIds,
        viewedStoryIds,
        followedAuthorIds,
        mySocialProfile,
        profilesById,
        uiToastMessage,
        uiToastTick,
      ];
}
