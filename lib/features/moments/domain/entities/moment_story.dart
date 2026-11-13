import 'package:equatable/equatable.dart';

/// Represents a 24-hour status or photo story shared in the Moments community.
class MomentStory extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String countryFlag;
  final String? mediaUrl;
  final String caption;
  final int bgGradientIndex;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewsCount;
  final int likesCount;
  final bool isLikedByMe;

  const MomentStory({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.countryFlag,
    this.mediaUrl,
    required this.caption,
    this.bgGradientIndex = 0,
    required this.createdAt,
    required this.expiresAt,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  MomentStory copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? countryFlag,
    String? mediaUrl,
    String? caption,
    int? bgGradientIndex,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewsCount,
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return MomentStory(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      countryFlag: countryFlag ?? this.countryFlag,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      bgGradientIndex: bgGradientIndex ?? this.bgGradientIndex,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'countryFlag': countryFlag,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'bgGradientIndex': bgGradientIndex,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'isLikedByMe': isLikedByMe,
    };
  }

  factory MomentStory.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final expires = DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
        created.add(const Duration(hours: 24));
    return MomentStory(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'Player',
      authorAvatar: json['authorAvatar']?.toString() ?? '',
      countryFlag: json['countryFlag']?.toString() ?? '🇧🇩',
      mediaUrl: json['mediaUrl']?.toString(),
      caption: json['caption']?.toString() ?? '',
      bgGradientIndex: (json['bgGradientIndex'] as num?)?.toInt() ?? 0,
      createdAt: created,
      expiresAt: expires,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        authorAvatar,
        countryFlag,
        mediaUrl,
        caption,
        bgGradientIndex,
        createdAt,
        expiresAt,
        viewsCount,
        likesCount,
        isLikedByMe,
      ];
}
