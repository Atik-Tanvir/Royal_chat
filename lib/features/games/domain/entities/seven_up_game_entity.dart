import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing one of the 3 betting zones in 7 UP 7 DOWN (`WhatsApp Video`).
class SevenUpZone extends Equatable {
  final String id; // 'up', 'seven', 'down'
  final String title; // '8 ~ 12', '7', '2 ~ 6'
  final String payoutLabel; // '1:1 (2x)' or '1:4 (5x)'
  final double multiplier; // 2.0 (double) or 5.0 (1:4 profit + stake)
  final Color accentColor;
  final List<Color> gradientColors;

  const SevenUpZone({
    required this.id,
    required this.title,
    required this.payoutLabel,
    required this.multiplier,
    required this.accentColor,
    required this.gradientColors,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        payoutLabel,
        multiplier,
        accentColor,
        gradientColors,
      ];
}

const List<SevenUpZone> kSevenUpZones = [
  SevenUpZone(
    id: 'up',
    title: '8 ~ 12',
    payoutLabel: '1:1 (2x)',
    multiplier: 2.0,
    accentColor: Color(0xFFF59E0B),
    gradientColors: [Color(0xFF4C1119), Color(0xFF2D090F)],
  ),
  SevenUpZone(
    id: 'seven',
    title: '7',
    payoutLabel: '1:4 (5x)',
    multiplier: 5.0,
    accentColor: Color(0xFFFFD700),
    gradientColors: [Color(0xFF78350F), Color(0xFF451A03)],
  ),
  SevenUpZone(
    id: 'down',
    title: '2 ~ 6',
    payoutLabel: '1:1 (2x)',
    multiplier: 2.0,
    accentColor: Color(0xFF10B981),
    gradientColors: [Color(0xFF3E3B09), Color(0xFF242105)],
  ),
];

/// Domain entity representing the 2 rolled 6-sided dice and resulting zone.
class DiceRollOutcome extends Equatable {
  final int die1;
  final int die2;

  const DiceRollOutcome({
    required this.die1,
    required this.die2,
  });

  int get sum => die1 + die2;

  String get zoneId {
    if (sum >= 8) return 'up';
    if (sum == 7) return 'seven';
    return 'down';
  }

  SevenUpZone get winningZone {
    return kSevenUpZones.firstWhere((z) => z.id == zoneId);
  }

  @override
  List<Object?> get props => [die1, die2];
}
