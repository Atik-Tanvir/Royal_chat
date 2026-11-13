import 'package:equatable/equatable.dart';

/// Community Moment post entity supporting original status/photo posts and reposts.
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
  final int sharesCount;
  final bool isLiked;
  final String category;
  final String? location;
  final bool isRepost;
  final String? repostedFromAuthor;
  final String? repostedFromPostId;

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
    this.sharesCount = 0,
    this.isLiked = false,
    this.category = 'Moments',
    this.location,
    this.isRepost = false,
    this.repostedFromAuthor,
    this.repostedFromPostId,
  });

  MomentPost copyWith({
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? countryFlag,
    int? authorLevel,
    String? content,
    List<String>? imageUrls,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    String? category,
    String? location,
    bool? isRepost,
    String? repostedFromAuthor,
    String? repostedFromPostId,
  }) {
    return MomentPost(
      id: id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      countryFlag: countryFlag ?? this.countryFlag,
      authorLevel: authorLevel ?? this.authorLevel,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      category: category ?? this.category,
      location: location ?? this.location,
      isRepost: isRepost ?? this.isRepost,
      repostedFromAuthor: repostedFromAuthor ?? this.repostedFromAuthor,
      repostedFromPostId: repostedFromPostId ?? this.repostedFromPostId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'countryFlag': countryFlag,
      'authorLevel': authorLevel,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'isLiked': isLiked,
      'category': category,
      'location': location,
      'isRepost': isRepost,
      'repostedFromAuthor': repostedFromAuthor,
      'repostedFromPostId': repostedFromPostId,
    };
  }

  factory MomentPost.fromJson(Map<String, dynamic> json) {
    return MomentPost(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'Player',
      authorAvatar: json['authorAvatar']?.toString() ?? '',
      countryFlag: json['countryFlag']?.toString() ?? '🇧🇩',
      authorLevel: (json['authorLevel'] as num?)?.toInt() ?? 1,
      content: json['content']?.toString() ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? const []),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      category: json['category']?.toString() ?? 'Moments',
      location: json['location']?.toString(),
      isRepost: json['isRepost'] as bool? ?? false,
      repostedFromAuthor: json['repostedFromAuthor']?.toString(),
      repostedFromPostId: json['repostedFromPostId']?.toString(),
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
        sharesCount,
        isLiked,
        category,
        location,
        isRepost,
        repostedFromAuthor,
        repostedFromPostId,
      ];
}
