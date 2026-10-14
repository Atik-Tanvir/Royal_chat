import 'package:equatable/equatable.dart';
import '../../domain/entities/game_block.dart';
import '../../domain/entities/polyomino_shape.dart';

class BlockMeState extends Equatable {
  final List<List<BlockItem>> grid;
  final List<PolyominoShape> availableShapes;
  final int score;
  final int multiplier;
  final int lives;
  final int dailyRank;
  final int monthlyRank;
  final bool hasClearedLines;

  const BlockMeState({
    required this.grid,
    required this.availableShapes,
    this.score = 941249408,
    this.multiplier = 256,
    this.lives = 3,
    this.dailyRank = 11,
    this.monthlyRank = 10,
    this.hasClearedLines = false,
  });

  BlockMeState copyWith({
    List<List<BlockItem>>? grid,
    List<PolyominoShape>? availableShapes,
    int? score,
    int? multiplier,
    int? lives,
    int? dailyRank,
    int? monthlyRank,
    bool? hasClearedLines,
  }) {
    return BlockMeState(
      grid: grid ?? this.grid,
      availableShapes: availableShapes ?? this.availableShapes,
      score: score ?? this.score,
      multiplier: multiplier ?? this.multiplier,
      lives: lives ?? this.lives,
      dailyRank: dailyRank ?? this.dailyRank,
      monthlyRank: monthlyRank ?? this.monthlyRank,
      hasClearedLines: hasClearedLines ?? this.hasClearedLines,
    );
  }

  @override
  List<Object?> get props => [
        grid,
        availableShapes,
        score,
        multiplier,
        lives,
        dailyRank,
        monthlyRank,
        hasClearedLines,
      ];
}
