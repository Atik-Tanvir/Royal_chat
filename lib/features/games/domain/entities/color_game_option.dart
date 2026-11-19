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

/// The 3 Color Zones for Color Spin (Vibrant RGB Neon Palette matching UI Mockup):
/// RED (Win 1:2), VIOLET (Win 1:5), GREEN (Win 1:2)
const List<ColorGameOption> kColorGameOptions = [
  ColorGameOption(
    id: 'red',
    name: 'RED',
    payoutLabel: 'Win 1:2',
    multiplier: 2.0,
    gradientColors: [Color(0xFFFF001E), Color(0xFFD50000)],
    accentColor: Color(0xFFFF001E),
    emoji: '🔴',
  ),
  ColorGameOption(
    id: 'violet',
    name: 'VIOLET',
    payoutLabel: 'Win 1:5',
    multiplier: 5.0,
    gradientColors: [Color(0xFF7C00FF), Color(0xFF6200D9)],
    accentColor: Color(0xFF7C00FF),
    emoji: '🟣',
  ),
  ColorGameOption(
    id: 'green',
    name: 'GREEN',
    payoutLabel: 'Win 1:2',
    multiplier: 2.0,
    gradientColors: [Color(0xFF00C853), Color(0xFF00A843)],
    accentColor: Color(0xFF00C853),
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
