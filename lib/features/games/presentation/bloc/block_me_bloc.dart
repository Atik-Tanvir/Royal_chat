import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/wallet_transaction_service.dart';
import '../../../profile/domain/entities/wallet_transaction.dart';
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

    // Initial playable starting blocks
    grid[3][3] = const BlockItem(color: BlockColor.green, isFilled: true);
    grid[3][4] = const BlockItem(color: BlockColor.green, isFilled: true);
    grid[4][3] = const BlockItem(color: BlockColor.blue, isFilled: true);
    grid[4][4] = const BlockItem(color: BlockColor.blue, isFilled: true);

    return BlockMeState(
      grid: grid,
      availableShapes: ShapeGenerator.getSampleShapes(),
      score: 0,
      multiplier: 1,
      lives: 3,
      dailyRank: 1,
      monthlyRank: 1,
    );
  }

  Future<void> _onPlaceShape(PlaceShapeEvent event, Emitter<BlockMeState> emit) async {
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
    final addedScore = (clearedCount > 0 ? clearedCount * 500 : 50) * state.multiplier;
    final newScore = state.score + addedScore;
    final newMultiplier = clearedCount > 0 ? (state.multiplier + clearedCount).clamp(1, 50) : state.multiplier;

    // Update remaining shapes
    final remainingShapes = List<PolyominoShape>.from(state.availableShapes)
      ..removeWhere((s) => s.id == shape.id);

    emit(state.copyWith(
      grid: newGrid,
      availableShapes: remainingShapes.isEmpty ? ShapeGenerator.getSampleShapes() : remainingShapes,
      score: newScore,
      multiplier: newMultiplier,
      hasClearedLines: clearedCount > 0,
    ));

    // Award real coins if lines were cleared
    if (clearedCount > 0) {
      final rewardCoins = (clearedCount * 50).toDouble();
      final currentUserId = AuthSessionManager.currentUserId;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        try {
          final profileRes = await SupabaseConfig.client
              .from('profiles')
              .select('coin_balance')
              .eq('id', currentUserId)
              .maybeSingle();

          if (profileRes != null) {
            final currentCoins = (profileRes['coin_balance'] as num?)?.toDouble() ?? 0.0;
            final updatedCoins = currentCoins + rewardCoins;

            await SupabaseConfig.client
                .from('profiles')
                .update({'coin_balance': updatedCoins})
                .eq('id', currentUserId);

            await WalletTransactionService.recordTransaction(
              WalletTransaction(
                id: 'GM-${DateTime.now().millisecondsSinceEpoch}',
                userId: currentUserId,
                type: 'daily_reward',
                title: 'Block Me Game Clear Reward (+$rewardCoins 🪙)',
                amount: rewardCoins,
                currency: 'coin',
                status: 'Completed',
                gateway: 'Game Reward',
                createdAt: DateTime.now(),
              ),
            );
          }
        } catch (e) {
          debugPrint('[BlockMeBloc] Coin award error: $e');
        }
      }
    }
  }
}
