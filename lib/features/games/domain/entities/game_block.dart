import 'package:flutter/material.dart';

enum BlockColor {
  none,
  green,
  orange,
  blue,
  purple,
}

class BlockItem {
  final BlockColor color;
  final bool isFilled;

  const BlockItem({
    this.color = BlockColor.none,
    this.isFilled = false,
  });

  Color get displayColor {
    switch (color) {
      case BlockColor.green:
        return const Color(0xFF10B981);
      case BlockColor.orange:
        return const Color(0xFFF97316);
      case BlockColor.blue:
        return const Color(0xFF3B82F6);
      case BlockColor.purple:
        return const Color(0xFF8B5CF6);
      case BlockColor.none:
        return Colors.transparent;
    }
  }

  Color get lightBevelColor {
    switch (color) {
      case BlockColor.green:
        return const Color(0xFF34D399);
      case BlockColor.orange:
        return const Color(0xFFFB923C);
      case BlockColor.blue:
        return const Color(0xFF60A5FA);
      case BlockColor.purple:
        return const Color(0xFFA78BFA);
      case BlockColor.none:
        return Colors.transparent;
    }
  }

  Color get darkBevelColor {
    switch (color) {
      case BlockColor.green:
        return const Color(0xFF047857);
      case BlockColor.orange:
        return const Color(0xFFC2410C);
      case BlockColor.blue:
        return const Color(0xFF1D4ED8);
      case BlockColor.purple:
        return const Color(0xFF6D28D9);
      case BlockColor.none:
        return Colors.transparent;
    }
  }
}
