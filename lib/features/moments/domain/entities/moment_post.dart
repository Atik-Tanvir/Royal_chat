import 'package:equatable/equatable.dart';

class MomentPost extends Equatable {
  final String id;
  final String authorId;
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
  final String category;
  final String? location;

  const MomentPost({
    required this.id,
    this.authorId = '',
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
    this.category = 'Moments',
    this.location,
  });

  MomentPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return MomentPost(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      countryFlag: countryFlag,
      authorLevel: authorLevel,
      content: content,
      imageUrls: imageUrls,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      category: category,
      location: location,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
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
        category,
        location,
      ];
}
