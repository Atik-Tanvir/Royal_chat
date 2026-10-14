import 'game_block.dart';

class PolyominoShape {
  final String id;
  final List<List<bool>> matrix;
  final BlockColor color;

  const PolyominoShape({
    required this.id,
    required this.matrix,
    required this.color,
  });

  int get rows => matrix.length;
  int get cols => matrix[0].length;
}

class ShapeGenerator {
  ShapeGenerator._();

  static List<PolyominoShape> getSampleShapes() {
    return [
      // L-Shape (Orange)
      const PolyominoShape(
        id: 'shape_l',
        matrix: [
          [true, false],
          [true, false],
          [true, true],
        ],
        color: BlockColor.orange,
      ),
      // 2x2 Square (Blue)
      const PolyominoShape(
        id: 'shape_square',
        matrix: [
          [true, true],
          [true, true],
        ],
        color: BlockColor.blue,
      ),
      // T-Shape (Green)
      const PolyominoShape(
        id: 'shape_t',
        matrix: [
          [true, true, true],
          [false, true, false],
        ],
        color: BlockColor.green,
      ),
    ];
  }
}
