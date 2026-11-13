import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing one of the 3 Color Zones in the Color Spin Game (`game.game 2.html`).
class ColorGameOption extends Equatable {
  final String id;
  final String name;
  final String payoutLabel;
  final double multiplier;
  final List<Color> gradientColors;
  final Color accentColor;
  final String emoji;

  const ColorGameOption({
    required this.id,
    required this.name,
    required this.payoutLabel,
    required this.multiplier,
    required this.gradientColors,
    required this.accentColor,
    required this.emoji,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        payoutLabel,
        multiplier,
        gradientColors,
        accentColor,
        emoji,
      ];
}

/// The 3 Color Zones from `game.game 2.html`: RED (1:2), VIOLET (1:4.5), GREEN (1:2)
const List<ColorGameOption> kColorGameOptions = [
  ColorGameOption(
    id: 'red',
    name: 'RED',
    payoutLabel: 'Win 1:2',
    multiplier: 2.0,
    gradientColors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    accentColor: Color(0xFFFF416C),
    emoji: '🔴',
  ),
  ColorGameOption(
    id: 'violet',
    name: 'VIOLET',
    payoutLabel: 'Win 1:4.5',
    multiplier: 4.5,
    gradientColors: [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
    accentColor: Color(0xFF8A2BE2),
    emoji: '🟣',
  ),
  ColorGameOption(
    id: 'green',
    name: 'GREEN',
    payoutLabel: 'Win 1:2',
    multiplier: 2.0,
    gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    accentColor: Color(0xFF38EF7D),
    emoji: '🟢',
  ),
];

/// Weighted outcome pool matching `game.game 2.html`:
/// ['red', 'green', 'violet', 'red', 'green']
final List<ColorGameOption> kColorOutcomePool = [
  kColorGameOptions[0], // RED
  kColorGameOptions[2], // GREEN
  kColorGameOptions[1], // VIOLET
  kColorGameOptions[0], // RED
  kColorGameOptions[2], // GREEN
];
