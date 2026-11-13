import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing one of the 8 prediction items in the Bucket Game.
class BucketGameItem extends Equatable {
  final String id;
  final String nameBn;
  final String nameEn;
  final String icon;
  final Color accentColor;

  const BucketGameItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.icon,
    required this.accentColor,
  });

  @override
  List<Object?> get props => [id, nameBn, nameEn, icon, accentColor];
}

/// The exact 8 items from RoyaleChat / Gemgala 8-Item Bucket Prediction (`game.game.html`)
const List<BucketGameItem> kBucketGameItems = [
  BucketGameItem(
    id: 'bucket',
    nameBn: 'বালতি',
    nameEn: 'Bucket',
    icon: '🪣',
    accentColor: Color(0xFF00E5FF),
  ),
  BucketGameItem(
    id: 'mug',
    nameBn: 'মগ',
    nameEn: 'Mug',
    icon: '🥛',
    accentColor: Color(0xFF38BDF8),
  ),
  BucketGameItem(
    id: 'flower',
    nameBn: 'ফুল',
    nameEn: 'Flower',
    icon: '🌸',
    accentColor: Color(0xFFF472B6),
  ),
  BucketGameItem(
    id: 'star',
    nameBn: 'তারা',
    nameEn: 'Star',
    icon: '⭐',
    accentColor: Color(0xFFFACC15),
  ),
  BucketGameItem(
    id: 'diamond',
    nameBn: 'ডায়মন্ড',
    nameEn: 'Diamond',
    icon: '💎',
    accentColor: Color(0xFF60A5FA),
  ),
  BucketGameItem(
    id: 'crown',
    nameBn: 'মুকুট',
    nameEn: 'Crown',
    icon: '👑',
    accentColor: Color(0xFFFFB703),
  ),
  BucketGameItem(
    id: 'gift',
    nameBn: 'উপহার',
    nameEn: 'Gift',
    icon: '🎁',
    accentColor: Color(0xFFFF4D6D),
  ),
  BucketGameItem(
    id: 'heart',
    nameBn: 'হার্ট',
    nameEn: 'Heart',
    icon: '❤️',
    accentColor: Color(0xFFEF4444),
  ),
];

/// Domain entity representing a group member's live bet in Group Mode.
class GroupBetRecord extends Equatable {
  final String userId;
  final String userName;
  final String itemId;
  final int amount;
  final bool isSelf;

  const GroupBetRecord({
    required this.userId,
    required this.userName,
    required this.itemId,
    required this.amount,
    this.isSelf = false,
  });

  @override
  List<Object?> get props => [userId, userName, itemId, amount, isSelf];
}
