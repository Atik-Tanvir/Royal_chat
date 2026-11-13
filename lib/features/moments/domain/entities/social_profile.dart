import 'package:equatable/equatable.dart';

/// Social identity & profile details shown on the dedicated Social Profile screen.
class SocialProfileDetails extends Equatable {
  final String userId;
  final String usernameHandle;
  final String nickname;
  final String avatarUrl;
  final int coverGradientIndex;
  final String? coverImageUrl;
  final String bio;
  final String location;
  final String countryFlag;
  final int level;
  final String joinedLabel;
  final int followersCount;
  final int followingCount;

  const SocialProfileDetails({
    required this.userId,
    required this.usernameHandle,
    required this.nickname,
    required this.avatarUrl,
    this.coverGradientIndex = 0,
    this.coverImageUrl,
    this.bio = '',
    this.location = 'Dhaka, Bangladesh',
    this.countryFlag = '🇧🇩',
    this.level = 15,
    this.joinedLabel = 'Member since 2026',
    this.followersCount = 128,
    this.followingCount = 46,
  });

  SocialProfileDetails copyWith({
    String? userId,
    String? usernameHandle,
    String? nickname,
    String? avatarUrl,
    int? coverGradientIndex,
    String? coverImageUrl,
    String? bio,
    String? location,
    String? countryFlag,
    int? level,
    String? joinedLabel,
    int? followersCount,
    int? followingCount,
  }) {
    return SocialProfileDetails(
      userId: userId ?? this.userId,
      usernameHandle: usernameHandle ?? this.usernameHandle,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverGradientIndex: coverGradientIndex ?? this.coverGradientIndex,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      countryFlag: countryFlag ?? this.countryFlag,
      level: level ?? this.level,
      joinedLabel: joinedLabel ?? this.joinedLabel,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'usernameHandle': usernameHandle,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'coverGradientIndex': coverGradientIndex,
      'coverImageUrl': coverImageUrl,
      'bio': bio,
      'location': location,
      'countryFlag': countryFlag,
      'level': level,
      'joinedLabel': joinedLabel,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  factory SocialProfileDetails.fromJson(Map<String, dynamic> json) {
    return SocialProfileDetails(
      userId: json['userId']?.toString() ?? 'royal_guest',
      usernameHandle: json['usernameHandle']?.toString() ?? '@royalplayer',
      nickname: json['nickname']?.toString() ?? 'Royal Player',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      coverGradientIndex: (json['coverGradientIndex'] as num?)?.toInt() ?? 0,
      coverImageUrl: json['coverImageUrl']?.toString(),
      bio: json['bio']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Dhaka, Bangladesh',
      countryFlag: json['countryFlag']?.toString() ?? '🇧🇩',
      level: (json['level'] as num?)?.toInt() ?? 15,
      joinedLabel: json['joinedLabel']?.toString() ?? 'Member since 2026',
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 128,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 46,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        usernameHandle,
        nickname,
        avatarUrl,
        coverGradientIndex,
        coverImageUrl,
        bio,
        location,
        countryFlag,
        level,
        joinedLabel,
        followersCount,
        followingCount,
      ];
}
