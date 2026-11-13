import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../data/repositories/bucket_game_repository_impl.dart';
import '../../domain/entities/balloon_game_entity.dart';
import '../../domain/entities/games_control_config.dart';
import '../bloc/balloon_game_bloc.dart';
import '../bloc/balloon_game_event.dart';
import '../bloc/balloon_game_state.dart';
import 'balloon_game_canvas.dart';
import 'game_coin_controls_bar.dart';
import 'game_board_chrome.dart';
import 'rewarded_ad_player_dialog.dart';

/// Pure BLoC-driven Presentation Widget for Game #4: Hot Air Balloon (Solo Arcade).
/// - 100% English UI & Play Store Hot Air Balloon visual layout
/// - Speed rises sharply past 40 seconds
/// - Free Play earns coins + Optional 2x Double Stake Challenge (speedier progressive curve)
/// - Admin-controlled Rewarded Ads when coins run out or via Free Coins button
class BalloonSkyGameView extends StatelessWidget {
  const BalloonSkyGameView({super.key});

  @override
  Widget build(BuildContext context) {
    final initialCoinBalance = context.read<ProfileBloc>().state.profile.coinBalance;

    return BlocProvider<BalloonGameBloc>(
      create: (_) => BalloonGameBloc(repository: BucketGameRepositoryImpl())
        ..add(InitBalloonGameEvent(initialUserCoinBalance: initialCoinBalance)),
      child: const _BalloonSkyViewContent(),
    );
  }
}

class _BalloonSkyViewContent extends StatefulWidget {
  const _BalloonSkyViewContent();

  @override
  State<_BalloonSkyViewContent> createState() => _BalloonSkyViewContentState();
}

class _BalloonSkyViewContentState extends State<_BalloonSkyViewContent> {
  final TextEditingController _stakeController =
      TextEditingController(text: '100');

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.profile.coinBalance != curr.profile.coinBalance,
          listener: (context, profileState) {
            final gameState = context.read<BalloonGameBloc>().state;
            if (gameState.syncedUserCoinBalance !=
                profileState.profile.coinBalance) {
              context.read<BalloonGameBloc>().add(
                    SyncBalloonUserBalanceEvent(
                        profileState.profile.coinBalance),
                  );
            }
          },
        ),
        BlocListener<BalloonGameBloc, BalloonGameState>(
          listenWhen: (prev, curr) =>
              prev.profileBalanceSyncTick != curr.profileBalanceSyncTick,
          listener: (context, state) {
            context.read<ProfileBloc>().add(
                  ProfileBalancesUpdatedFromRealtimeEvent(
                    coinBalance: state.syncedUserCoinBalance,
                  ),
                );
          },
        ),
        BlocListener<BalloonGameBloc, BalloonGameState>(
          listenWhen: (prev, curr) =>
              prev.stakeInputAmount != curr.stakeInputAmount,
          listener: (context, state) {
            final newText = state.stakeInputAmount.toString();
            if (_stakeController.text != newText) {
              _stakeController.text = newText;
              _stakeController.selection = TextSelection.fromPosition(
                TextPosition(offset: newText.length),
              );
            }
          },
        ),
        BlocListener<BalloonGameBloc, BalloonGameState>(
          listenWhen: (prev, curr) =>
              prev.openWatchAdModalTick != curr.openWatchAdModalTick,
          listener: (context, state) {
            final gameBloc = context.read<BalloonGameBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => RewardedAdPlayerDialog(
                config: state.rewardedAdsConfig,
                onClaimReward: (ad) =>
                    gameBloc.add(ClaimBalloonAdRewardEvent(ad)),
              ),
            );
          },
        ),
        BlocListener<BalloonGameBloc, BalloonGameState>(
          listenWhen: (prev, curr) => prev.uiFeedbackTick != curr.uiFeedbackTick,
          listener: (context, state) {
            final msg = state.uiFeedbackMessage;
            if (msg == null || msg.isEmpty) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: state.uiFeedbackNeedsAdRefill
                      ? Colors.redAccent
                      : const Color(0xFF10B981),
                  duration: const Duration(seconds: 2),
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<BalloonGameBloc, BalloonGameState>(
        builder: (context, state) {
          final gameBloc = context.read<BalloonGameBloc>();
          final currentUid = AuthSessionManager.currentUserId;
          final balance = (currentUid == null || currentUid.isEmpty)
              ? state.guestFallbackBalance
              : state.syncedUserCoinBalance;

          final isPlayingOrPaused = state.phase == BalloonGamePhase.playing ||
              state.phase == BalloonGamePhase.paused;
          final isDouble = state.playMode == BalloonPlayMode.doubleStake;

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0C243D), Color(0xFF081424), Color(0xFF050A14)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.78),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.22),
                  blurRadius: 18,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Header (Single-Player Sky Arcade)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🎈 Balloon Sky (Solo)',
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                'Earn Coins • Speed Surges >${state.speedBoostAfterSeconds}s • Optional ${GamesControlConfig.formatMultiplier(state.doubleStakeMultiplier)} Stake',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: Color(0xFF7DD3FC),
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Solo Only',
                                style: TextStyle(
                                  color: Color(0xFF7DD3FC),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balance + Admin-Controlled Free Coins Bar (reusing shared widget)
                  GameStatsBar(
                    balance: balance,
                    totalPoolCount: state.bestScore,
                    statsLabel: 'Best: ',
                    showRightCoinIcon: false,
                    isLoadingAds: state.isLoadingAds,
                    onWatchAdTap: () => gameBloc.add(
                      const FetchBalloonRewardedAdsEvent(
                        openDialogAfterFetch: true,
                      ),
                    ),
                  ),

                  if (!state.gamesConfig.isGamePlayable('game_balloon_sky'))
                    const GameFrozenBanner(),

                  // Mode Selector: Free Play (Earn) vs Double Stake (2x Speed+)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildModeCard(
                            label: '🆓 Free Earn',
                            sub: 'No Risk • +${state.goldBubbleCoins}/+${state.standardBubbleCoins} Bubbles',
                            isSelected: !isDouble,
                            accentColor: const Color(0xFF38BDF8),
                            enabled: !isPlayingOrPaused,
                            onTap: () => gameBloc.add(
                              const SelectBalloonPlayModeEvent(
                                BalloonPlayMode.freeEarn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModeCard(
                            label:
                                '💎 ${GamesControlConfig.formatMultiplier(state.doubleStakeMultiplier)} Double Stake',
                            sub: 'Speed+ • Clear ${state.doubleTargetSeconds}s Goal',
                            isSelected: isDouble,
                            accentColor: const Color(0xFFFBBF24),
                            enabled: !isPlayingOrPaused,
                            onTap: () => gameBloc.add(
                              const SelectBalloonPlayModeEvent(
                                BalloonPlayMode.doubleStake,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Live Play Store Hot Air Balloon Canvas
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: BalloonGameCanvas(
                      phase: state.phase,
                      playMode: state.playMode,
                      runSeedTick: state.runSeedTick,
                      activeRunStake: state.activeRunStake,
                      bestScore: state.bestScore,
                      lastRunSummary: state.lastRunSummary,
                      doubleTargetSeconds: state.doubleTargetSeconds,
                      doubleStakeMultiplier: state.doubleStakeMultiplier,
                      standardBubbleCoins: state.standardBubbleCoins,
                      goldBubbleCoins: state.goldBubbleCoins,
                      speedBoostAfterSeconds: state.speedBoostAfterSeconds,
                      onStartTap: () =>
                          gameBloc.add(const StartBalloonRunEvent()),
                      onTogglePauseTap: () =>
                          gameBloc.add(const TogglePauseBalloonRunEvent()),
                      onRunFinished: ({
                        required score,
                        required bubbleCoinsEarned,
                        required survivedSeconds,
                        required doubleTargetCleared,
                      }) {
                        gameBloc.add(FinishBalloonRunEvent(
                          score: score,
                          bubbleCoinsEarned: bubbleCoinsEarned,
                          survivedSeconds: survivedSeconds,
                          doubleTargetCleared: doubleTargetCleared,
                        ));
                      },
                    ),
                  ),

                  // Coin Stake Selector shown in 2x Double Stake mode before launch
                  if (isDouble)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: AbsorbPointer(
                        absorbing: isPlayingOrPaused,
                        child: Opacity(
                          opacity: isPlayingOrPaused ? 0.5 : 1.0,
                          child: GameCoinControlsBar(
                            controller: _stakeController,
                            currentAmount: state.stakeInputAmount,
                            onDecrement: () => gameBloc.add(
                              const StepBalloonStakeCoinEvent(
                                isIncrement: false,
                              ),
                            ),
                            onIncrement: () => gameBloc.add(
                              const StepBalloonStakeCoinEvent(
                                isIncrement: true,
                              ),
                            ),
                            onTextChanged: (txt) => gameBloc.add(
                              UpdateBalloonCustomStakeTextEvent(txt),
                            ),
                            onPresetSelected: (val) => gameBloc.add(
                              SetBalloonPresetStakeEvent(val),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeCard({
    required String label,
    required String sub,
    required bool isSelected,
    required Color accentColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white12,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              style: const TextStyle(color: Colors.white60, fontSize: 9.2),
            ),
          ],
        ),
      ),
    );
  }
}
