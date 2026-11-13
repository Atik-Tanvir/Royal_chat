import 'package:equatable/equatable.dart';

enum SharePostTarget { repostFeed, shareToStory, copyLink }

abstract class MomentsEvent extends Equatable {
  const MomentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMomentsEvent extends MomentsEvent {}

class ChangeMomentTabEvent extends MomentsEvent {
  final String tab; // 'Follow', 'Moments', 'Video'

  const ChangeMomentTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class CreateMomentEvent extends MomentsEvent {
  final String content;
  final List<String> imageUrls;
  final String category;
  final String? location;
  final bool shareToStory;

  const CreateMomentEvent({
    required this.content,
    this.imageUrls = const [],
    this.category = 'Moments',
    this.location,
    this.shareToStory = false,
  });

  @override
  List<Object?> get props => [content, imageUrls, category, location, shareToStory];
}

class DeleteMomentEvent extends MomentsEvent {
  final String postId;

  const DeleteMomentEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ToggleLikePostEvent extends MomentsEvent {
  final String postId;

  const ToggleLikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class SharePostEvent extends MomentsEvent {
  final String postId;
  final SharePostTarget target;
  final String? note;

  const SharePostEvent({
    required this.postId,
    required this.target,
    this.note,
  });

  @override
  List<Object?> get props => [postId, target, note];
}

class LoadCommentsEvent extends MomentsEvent {
  final String postId;

  const LoadCommentsEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class AddCommentEvent extends MomentsEvent {
  final String postId;
  final String text;

  const AddCommentEvent({
    required this.postId,
    required this.text,
  });

  @override
  List<Object?> get props => [postId, text];
}

class CreateStoryEvent extends MomentsEvent {
  final String caption;
  final String? mediaUrl;
  final int bgGradientIndex;

  const CreateStoryEvent({
    required this.caption,
    this.mediaUrl,
    this.bgGradientIndex = 0,
  });

  @override
  List<Object?> get props => [caption, mediaUrl, bgGradientIndex];
}

class MarkStoryViewedEvent extends MomentsEvent {
  final String storyId;

  const MarkStoryViewedEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class ToggleLikeStoryEvent extends MomentsEvent {
  final String storyId;

  const ToggleLikeStoryEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class DeleteStoryEvent extends MomentsEvent {
  final String storyId;

  const DeleteStoryEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class ToggleFollowAuthorEvent extends MomentsEvent {
  final String authorId;
  final String authorName;

  const ToggleFollowAuthorEvent({
    required this.authorId,
    required this.authorName,
  });

  @override
  List<Object?> get props => [authorId, authorName];
}

class UpdateMySocialProfileEvent extends MomentsEvent {
  final String nickname;
  final String usernameHandle;
  final String bio;
  final String location;
  final String avatarUrl;
  final int coverGradientIndex;
  final String? coverImageUrl;

  const UpdateMySocialProfileEvent({
    required this.nickname,
    required this.usernameHandle,
    required this.bio,
    required this.location,
    required this.avatarUrl,
    this.coverGradientIndex = 0,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        nickname,
        usernameHandle,
        bio,
        location,
        avatarUrl,
        coverGradientIndex,
        coverImageUrl,
      ];
}

class MomentsUpdatedFromRealtimeEvent extends MomentsEvent {
  final Map<String, dynamic> payload;

  const MomentsUpdatedFromRealtimeEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class LikedPostsLoadedEvent extends MomentsEvent {
  final Set<String> likedPostIds;

  const LikedPostsLoadedEvent(this.likedPostIds);

  @override
  List<Object?> get props => [likedPostIds];
}
