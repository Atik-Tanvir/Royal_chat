import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../party/domain/entities/party_room.dart';

/// Shared gradient palettes used by Status Stories and Story Viewer.
const List<List<Color>> kStoryGradients = [
  [Color(0xFF0E6B47), Color(0xFF063B27)],
  [Color(0xFFFF8F00), Color(0xFFE65100)],
  [Color(0xFF7B1FA2), Color(0xFF4A148C)],
  [Color(0xFF1565C0), Color(0xFF0D47A1)],
  [Color(0xFFC2185B), Color(0xFF880E4F)],
  [Color(0xFF00796B), Color(0xFF004D40)],
];

/// Represents a 24-hour status or popular room story shared in the Moments feed.
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

  /// Optional Room promotion fields (when promoting popular live audio/game rooms)
  final String? roomId;
  final String? roomTitle;
  final String? roomCategory;
  final int? roomOnlineCount;

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
    this.roomId,
    this.roomTitle,
    this.roomCategory,
    this.roomOnlineCount,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isRoomStory => roomId != null && roomId!.isNotEmpty;

  /// Converts this room story into a PartyRoom instance to open the live room directly.
  PartyRoom toPartyRoom() {
    return PartyRoom(
      id: roomId ?? 'room_$id',
      title: (roomTitle != null && roomTitle!.isNotEmpty) ? roomTitle! : caption,
      hostName: authorName,
      hostAvatar: authorAvatar,
      countryFlag: countryFlag,
      onlineCount: roomOnlineCount ?? 1,
      category: roomCategory ?? 'Chatroom',
      seatedAvatars: const [],
      isLive: true,
    );
  }

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
    String? roomId,
    String? roomTitle,
    String? roomCategory,
    int? roomOnlineCount,
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
      roomId: roomId ?? this.roomId,
      roomTitle: roomTitle ?? this.roomTitle,
      roomCategory: roomCategory ?? this.roomCategory,
      roomOnlineCount: roomOnlineCount ?? this.roomOnlineCount,
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
      'roomId': roomId,
      'roomTitle': roomTitle,
      'roomCategory': roomCategory,
      'roomOnlineCount': roomOnlineCount,
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
      roomId: json['roomId']?.toString(),
      roomTitle: json['roomTitle']?.toString(),
      roomCategory: json['roomCategory']?.toString(),
      roomOnlineCount: (json['roomOnlineCount'] as num?)?.toInt(),
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
        roomId,
        roomTitle,
        roomCategory,
        roomOnlineCount,
      ];
}
