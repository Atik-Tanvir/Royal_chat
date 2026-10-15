import 'package:equatable/equatable.dart';

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

  const CreateMomentEvent({
    required this.content,
    this.imageUrls = const [],
    this.category = 'Moments',
    this.location,
  });

  @override
  List<Object?> get props => [content, imageUrls, category, location];
}

class ToggleLikePostEvent extends MomentsEvent {
  final String postId;

  const ToggleLikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
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

