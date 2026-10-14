import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_block.dart';
import '../../domain/entities/polyomino_shape.dart';
import 'block_me_event.dart';
import 'block_me_state.dart';

class BlockMeBloc extends Bloc<BlockMeEvent, BlockMeState> {
  BlockMeBloc() : super(_createInitialState()) {
    on<InitGameEvent>((event, emit) {
      emit(_createInitialState());
    });

    on<PlaceShapeEvent>(_onPlaceShape);
    on<ResetGameEvent>((event, emit) {
      emit(_createInitialState());
    });
  }

  static BlockMeState _createInitialState() {
    // 8x8 Grid
    final grid = List.generate(
      8,
      (r) => List.generate(
        8,
        (c) => const BlockItem(color: BlockColor.none, isFilled: false),
      ),
    );

    // Replicate Screenshot 5 exact board layout:
    // Green cluster (Rows 3, 4, 5 - Cols 0, 1, 2)
    for (int r = 3; r <= 5; r++) {
      for (int c = 0; c <= 2; c++) {
        grid[r][c] = const BlockItem(color: BlockColor.green, isFilled: true);
      }
    }
    // Row 6 (Cols 0, 1 green, col 2 blue)
    grid[6][0] = const BlockItem(color: BlockColor.green, isFilled: true);
    grid[6][1] = const BlockItem(color: BlockColor.green, isFilled: true);
    grid[6][2] = const BlockItem(color: BlockColor.blue, isFilled: true);

    // Row 7 (Bottom line: cols 0..6 purple)
    for (int c = 0; c <= 6; c++) {
      grid[7][c] = const BlockItem(color: BlockColor.purple, isFilled: true);
    }

    // Column 7 (Right edge: purple)
    for (int r = 0; r <= 7; r++) {
      grid[r][7] = const BlockItem(color: BlockColor.purple, isFilled: true);
    }

    // Column 6 (purple vertical extension)
    grid[4][6] = const BlockItem(color: BlockColor.purple, isFilled: true);
    grid[5][6] = const BlockItem(color: BlockColor.purple, isFilled: true);
    grid[6][6] = const BlockItem(color: BlockColor.purple, isFilled: true);

    // Orange cluster near top-right (Row 0: cols 4, 5, 6)
    grid[0][4] = const BlockItem(color: BlockColor.orange, isFilled: true);
    grid[0][5] = const BlockItem(color: BlockColor.orange, isFilled: true);
    grid[0][6] = const BlockItem(color: BlockColor.orange, isFilled: true);

    // Orange 2x1 block (Rows 3, 4 - Col 5)
    grid[3][5] = const BlockItem(color: BlockColor.orange, isFilled: true);
    grid[4][5] = const BlockItem(color: BlockColor.orange, isFilled: true);

    return BlockMeState(
      grid: grid,
      availableShapes: ShapeGenerator.getSampleShapes(),
      score: 941249408,
      multiplier: 256,
      lives: 3,
      dailyRank: 11,
      monthlyRank: 10,
    );
  }

  void _onPlaceShape(PlaceShapeEvent event, Emitter<BlockMeState> emit) {
    final newGrid = List<List<BlockItem>>.generate(
      8,
      (r) => List<BlockItem>.from(state.grid[r]),
    );

    final shape = event.shape;
    bool canPlace = true;

    // Check bounds & collisions
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c]) {
          final targetR = event.gridRow + r;
          final targetC = event.gridCol + c;
          if (targetR >= 8 || targetC >= 8 || newGrid[targetR][targetC].isFilled) {
            canPlace = false;
            break;
          }
        }
      }
    }

    if (!canPlace) return;

    // Place shape
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c]) {
          newGrid[event.gridRow + r][event.gridCol + c] = BlockItem(
            color: shape.color,
            isFilled: true,
          );
        }
      }
    }

    // Check full rows & columns to clear
    final fullRows = <int>[];
    for (int r = 0; r < 8; r++) {
      if (newGrid[r].every((b) => b.isFilled)) fullRows.add(r);
    }

    final fullCols = <int>[];
    for (int c = 0; c < 8; c++) {
      if (List.generate(8, (r) => newGrid[r][c]).every((b) => b.isFilled)) {
        fullCols.add(c);
      }
    }

    // Clear filled rows/cols
    for (final r in fullRows) {
      for (int c = 0; c < 8; c++) {
        newGrid[r][c] = const BlockItem(color: BlockColor.none, isFilled: false);
      }
    }
    for (final c in fullCols) {
      for (int r = 0; r < 8; r++) {
        newGrid[r][c] = const BlockItem(color: BlockColor.none, isFilled: false);
      }
    }

    final clearedCount = fullRows.length + fullCols.length;
    final addedScore = (clearedCount > 0 ? clearedCount * 1000 : 100) * state.multiplier;

    // Update remaining shapes
    final remainingShapes = List<PolyominoShape>.from(state.availableShapes)
      ..removeWhere((s) => s.id == shape.id);

    emit(state.copyWith(
      grid: newGrid,
      availableShapes: remainingShapes.isEmpty ? ShapeGenerator.getSampleShapes() : remainingShapes,
      score: state.score + addedScore,
      hasClearedLines: clearedCount > 0,
    ));
  }
}
