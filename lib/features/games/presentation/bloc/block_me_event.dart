import 'package:equatable/equatable.dart';
import '../../domain/entities/polyomino_shape.dart';

abstract class BlockMeEvent extends Equatable {
  const BlockMeEvent();

  @override
  List<Object?> get props => [];
}

class InitGameEvent extends BlockMeEvent {}

class PlaceShapeEvent extends BlockMeEvent {
  final PolyominoShape shape;
  final int gridRow;
  final int gridCol;

  const PlaceShapeEvent({
    required this.shape,
    required this.gridRow,
    required this.gridCol,
  });

  @override
  List<Object?> get props => [shape, gridRow, gridCol];
}

class ResetGameEvent extends BlockMeEvent {}
