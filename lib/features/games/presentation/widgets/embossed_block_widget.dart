import 'package:flutter/material.dart';
import '../../domain/entities/game_block.dart';

class EmbossedBlockWidget extends StatelessWidget {
  final BlockItem block;
  final double size;

  const EmbossedBlockWidget({
    super.key,
    required this.block,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (!block.isFilled) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF063A2C).withOpacity(0.6),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: block.displayColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            block.lightBevelColor,
            block.displayColor,
            block.darkBevelColor,
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: block.displayColor,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
            left: BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.2), width: 1.5),
            right: BorderSide(color: Colors.black.withValues(alpha: 0.2), width: 1.5),
          ),
        ),
      ),
    );
  }
}
