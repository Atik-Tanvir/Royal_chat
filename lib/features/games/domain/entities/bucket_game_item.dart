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

/// The 8 mixed all-star prediction items (Fruit Slot + Casino Arcade + Royal Luxury + Live Party Gifts)
const List<BucketGameItem> kBucketGameItems = [
  BucketGameItem(
    id: 'apple',
    nameBn: 'আপেল',
    nameEn: 'Apple',
    icon: '🍎',
    accentColor: Color(0xFFEF4444),
  ),
  BucketGameItem(
    id: 'watermelon',
    nameBn: 'তরমুজ',
    nameEn: 'Watermelon',
    icon: '🍉',
    accentColor: Color(0xFF10B981),
  ),
  BucketGameItem(
    id: 'bell',
    nameBn: 'ঘণ্টা',
    nameEn: 'Bell',
    icon: '🔔',
    accentColor: Color(0xFFFACC15),
  ),
  BucketGameItem(
    id: 'lucky7',
    nameBn: 'লাকি ৭',
    nameEn: 'Lucky 7',
    icon: '7️⃣',
    accentColor: Color(0xFFFF5722),
  ),
  BucketGameItem(
    id: 'diamond',
    nameBn: 'ডায়মন্ড',
    nameEn: 'Diamond',
    icon: '💎',
    accentColor: Color(0xFF00E5FF),
  ),
  BucketGameItem(
    id: 'crown',
    nameBn: 'মুকুট',
    nameEn: 'Crown',
    icon: '👑',
    accentColor: Color(0xFFFFB703),
  ),
  BucketGameItem(
    id: 'rocket',
    nameBn: 'রকেট',
    nameEn: 'Rocket',
    icon: '🚀',
    accentColor: Color(0xFF8B5CF6),
  ),
  BucketGameItem(
    id: 'heart',
    nameBn: 'হার্ট',
    nameEn: 'Heart',
    icon: '❤️',
    accentColor: Color(0xFFEC4899),
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
