import 'package:equatable/equatable.dart';

class MomentPost extends Equatable {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String countryFlag;
  final int authorLevel;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  const MomentPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.countryFlag,
    this.authorLevel = 1,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  MomentPost copyWith({
    int? likesCount,
    bool? isLiked,
  }) {
    return MomentPost(
      id: id,
      authorName: authorName,
      authorAvatar: authorAvatar,
      countryFlag: countryFlag,
      authorLevel: authorLevel,
      content: content,
      imageUrls: imageUrls,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorAvatar,
        countryFlag,
        authorLevel,
        content,
        imageUrls,
        createdAt,
        likesCount,
        commentsCount,
        isLiked,
      ];
}
