import 'package:flutter/material.dart';
import '../../domain/entities/game_block.dart';
import '../../domain/entities/polyomino_shape.dart';
import 'embossed_block_widget.dart';

class ShapePieceWidget extends StatelessWidget {
  final PolyominoShape shape;
  final double blockSize;

  const ShapePieceWidget({
    super.key,
    required this.shape,
    this.blockSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(shape.rows, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(shape.cols, (c) {
            final isCellFilled = shape.matrix[r][c];
            if (!isCellFilled) {
              return SizedBox(width: blockSize, height: blockSize);
            }
            return EmbossedBlockWidget(
              block: BlockItem(color: shape.color, isFilled: true),
              size: blockSize,
            );
          }),
        );
      }),
    );
  }
}
