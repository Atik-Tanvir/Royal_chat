import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/currency_badge.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../domain/entities/polyomino_shape.dart';
import '../bloc/block_me_bloc.dart';
import '../bloc/block_me_event.dart';
import '../bloc/block_me_state.dart';
import '../widgets/embossed_block_widget.dart';
import '../widgets/shape_piece_widget.dart';

class GamesTabPage extends StatefulWidget {
  const GamesTabPage({super.key});

  @override
  State<GamesTabPage> createState() => _GamesTabPageState();
}

class _GamesTabPageState extends State<GamesTabPage> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: BlocBuilder<BlockMeBloc, BlockMeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTopBar(state),
                  const SizedBox(height: 12),
                  _buildRankingBanner(state),
                  const SizedBox(height: 16),
                  _buildScoreHeader(state),
                  const SizedBox(height: 12),
                  _buildGameGrid(context, state),
                  const SizedBox(height: 20),
                  _buildBottomShapesTray(context, state),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BlockMeState state) {
    return Row(
      children: [
        const CurrencyBadge(amount: '158.98K'),
        const SizedBox(width: 8),
        // Win more pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                'win more',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.emoji_events, color: AppColors.goldCoin, size: 14),
            ],
          ),
        ),
        const Spacer(),
        // Hearts / Lives counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.pinkAccent.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                '${state.lives}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.menu_book_rounded, color: AppColors.goldCoin),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: AppColors.goldCoin),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRankingBanner(BlockMeState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF139671).withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Game Icon Thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF0C4636),
              border: Border.all(color: AppColors.gemEmerald, width: 1.5),
            ),
            child: const Icon(Icons.grid_4x4_rounded, color: AppColors.gemEmerald, size: 24),
          ),
          const SizedBox(width: 12),
          // Daily Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Daily ${state.dailyRank}',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'Prize 3,363,328',
                  style: AppTextStyles.caption.copyWith(color: AppColors.goldCoin, fontSize: 9),
                ),
              ],
            ),
          ),
          // Monthly Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Monthly ${state.monthlyRank}',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'Prize 15,000,000',
                  style: AppTextStyles.caption.copyWith(color: AppColors.goldCoin, fontSize: 9),
                ),
              ],
            ),
          ),
          // Competitor Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
            ),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.accentOrange,
              child: Icon(Icons.person, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(BlockMeState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Competitor avatars stack with rank badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.purple,
                child: Icon(Icons.pets, size: 10, color: Colors.white),
              ),
              const SizedBox(width: 4),
              const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.gemEmerald,
                child: Icon(Icons.star, size: 10, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Text(
                '8',
                style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Big Score
        Text(
          '${state.score}',
          style: AppTextStyles.gameScore.copyWith(
            shadows: [
              const Shadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Multiplier Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF3366), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3366).withOpacity(0.5),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            'x${state.multiplier}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameGrid(BuildContext context, BlockMeState state) {
    const double boardPadding = 12.0;
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final gridWidth = screenWidth - (boardPadding * 2);
    final cellSize = gridWidth / 8.0;

    return Container(
      padding: const EdgeInsets.all(boardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF07382B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF139671),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 8x8 Grid
          Column(
            children: List.generate(8, (r) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (c) {
                  final block = state.grid[r][c];
                  return GestureDetector(
                    onTap: () {
                      if (state.availableShapes.isNotEmpty) {
                        context.read<BlockMeBloc>().add(
                              PlaceShapeEvent(
                                shape: state.availableShapes.first,
                                gridRow: r,
                                gridCol: c,
                              ),
                            );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: EmbossedBlockWidget(
                        block: block,
                        size: cellSize - 2.0,
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomShapesTray(BuildContext context, BlockMeState state) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Shape 1 (Left)
          if (state.availableShapes.isNotEmpty)
            _buildDraggableShape(context, state.availableShapes[0])
          else
            const SizedBox(width: 60),

          // Center: Starburst Animation matching Screenshot 5
          RotationTransition(
            turns: _sparkleController,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    AppColors.gemCyan.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
          ),

          // Shape 2 / 3 (Right)
          if (state.availableShapes.length > 1)
            _buildDraggableShape(context, state.availableShapes[1])
          else if (state.availableShapes.isNotEmpty)
            _buildDraggableShape(context, state.availableShapes[0])
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildDraggableShape(BuildContext context, PolyominoShape shape) {
    return GestureDetector(
      onTap: () {
        // Tap auto-finds first empty cell
        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            if (!context.read<BlockMeBloc>().state.grid[r][c].isFilled) {
              context.read<BlockMeBloc>().add(
                    PlaceShapeEvent(shape: shape, gridRow: r, gridCol: c),
                  );
              return;
            }
          }
        }
      },
      child: ShapePieceWidget(
        shape: shape,
        blockSize: 18,
      ),
    );
  }
}
