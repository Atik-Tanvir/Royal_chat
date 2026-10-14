import 'package:equatable/equatable.dart';

abstract class MomentsEvent extends Equatable {
  const MomentsEvent();

  @override
  List<Object?> get props => [];
}

class ChangeMomentTabEvent extends MomentsEvent {
  final String tab; // 'Follow', 'Moments', 'Video'

  const ChangeMomentTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class AddMomentPostEvent extends MomentsEvent {
  final String content;
  final List<String> images;

  const AddMomentPostEvent({required this.content, this.images = const []});

  @override
  List<Object?> get props => [content, images];
}

class ToggleLikePostEvent extends MomentsEvent {
  final String postId;

  const ToggleLikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}
