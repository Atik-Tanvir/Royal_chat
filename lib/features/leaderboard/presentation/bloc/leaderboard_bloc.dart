import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc()
      : super(
          const LeaderboardState(
            currentType: LeaderboardType.wealth,
            currentTimeframe: LeaderboardTimeframe.daily,
            entries: [],
            isAnonymous: false,
            myRank: 99,
            myBalance: '0',
          ),
        ) {
    on<LoadLeaderboardEvent>(_onLoadLeaderboard);
    on<ChangeLeaderboardTypeEvent>(_onChangeType);
    on<ChangeLeaderboardTimeframeEvent>(_onChangeTimeframe);
    on<ToggleAnonymousEvent>(_onToggleAnonymous);

    // Initial dynamic load from Supabase
    add(LoadLeaderboardEvent());
  }

  Future<void> _onLoadLeaderboard(LoadLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    final dynamicEntries = await _fetchDynamicEntries(state.currentType, state.currentTimeframe);
    emit(state.copyWith(entries: dynamicEntries));
  }

  Future<void> _onChangeType(ChangeLeaderboardTypeEvent event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(currentType: event.type));
    final dynamicEntries = await _fetchDynamicEntries(event.type, state.currentTimeframe);
    emit(state.copyWith(entries: dynamicEntries));
  }

  Future<void> _onChangeTimeframe(ChangeLeaderboardTimeframeEvent event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(currentTimeframe: event.timeframe));
    final dynamicEntries = await _fetchDynamicEntries(state.currentType, event.timeframe);
    emit(state.copyWith(entries: dynamicEntries));
  }

  Future<List<LeaderboardEntry>> _fetchDynamicEntries(LeaderboardType type, LeaderboardTimeframe timeframe) async {
    try {
      final typeStr = type.name;
      final response = await SupabaseConfig.client
          .from('leaderboards')
          .select()
          .eq('type', typeStr)
          .order('rank', ascending: true);

      if (response.isNotEmpty) {
        return (response as List).map((row) {
          final score = (row['score'] as num?)?.toDouble() ?? 1000000.0;
          String formatted;
          if (score >= 1000000) {
            formatted = '${(score / 1000000).toStringAsFixed(2)}M';
          } else if (score >= 1000) {
            formatted = '${(score / 1000).toStringAsFixed(1)}K';
          } else {
            formatted = score.toStringAsFixed(0);
          }

          final isAnon = row['is_anonymous'] as bool? ?? false;
          final userName = isAnon ? 'Anonymous Star' : (row['user_name'] as String? ?? 'Royal User');

          return LeaderboardEntry(
            rank: (row['rank'] as num?)?.toInt() ?? 1,
            username: userName,
            flagEmoji: row['country_flag'] as String? ?? '🇧🇩',
            gender: '♂',
            age: 21,
            level: 6,
            levelType: 'LV',
            amount: score,
            amountFormatted: formatted,
            isGems: type == LeaderboardType.charm,
            usdEquivalent: score * 0.0001,
            avatarUrl: !isAnon && (row['user_avatar'] as String?)?.isNotEmpty == true
                ? row['user_avatar'] as String
                : null,
            isVip: true,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('LeaderboardBloc: Supabase fetch error: $e');
    }

    return const [];
  }

  void _onToggleAnonymous(ToggleAnonymousEvent event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(isAnonymous: !state.isAnonymous));
  }
}
