import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  RealtimeChannel? _realtimeChannel;

  LeaderboardBloc()
      : super(
          const LeaderboardState(
            currentType: LeaderboardType.wealth,
            currentTimeframe: LeaderboardTimeframe.daily,
            entries: [],
            isAnonymous: false,
            myRank: 1,
            myBalance: '0 🪙',
          ),
        ) {
    on<LoadLeaderboardEvent>(_onLoadLeaderboard);
    on<ChangeLeaderboardTypeEvent>(_onChangeType);
    on<ChangeLeaderboardTimeframeEvent>(_onChangeTimeframe);
    on<ToggleAnonymousEvent>(_onToggleAnonymous);

    // Initial dynamic load from Supabase
    add(LoadLeaderboardEvent());
    _subscribeToProfilesRealtime();
  }

  @override
  Future<void> close() {
    _realtimeChannel?.unsubscribe();
    return super.close();
  }

  void _subscribeToProfilesRealtime() {
    try {
      _realtimeChannel = SupabaseConfig.client
          .channel('public:leaderboard_profiles')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: (_) {
              add(LoadLeaderboardEvent());
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[LeaderboardBloc] Realtime subscription error: $e');
    }
  }

  Future<void> _onLoadLeaderboard(LoadLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    final dynamicEntries = await _fetchDynamicEntries(state.currentType, state.currentTimeframe);
    final (rank, balance) = _calculateMyStats(dynamicEntries, state.currentType);
    emit(state.copyWith(entries: dynamicEntries, myRank: rank, myBalance: balance));
  }

  Future<void> _onChangeType(ChangeLeaderboardTypeEvent event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(currentType: event.type));
    final dynamicEntries = await _fetchDynamicEntries(event.type, state.currentTimeframe);
    final (rank, balance) = _calculateMyStats(dynamicEntries, event.type);
    emit(state.copyWith(entries: dynamicEntries, myRank: rank, myBalance: balance));
  }

  Future<void> _onChangeTimeframe(ChangeLeaderboardTimeframeEvent event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(currentTimeframe: event.timeframe));
    final dynamicEntries = await _fetchDynamicEntries(state.currentType, event.timeframe);
    final (rank, balance) = _calculateMyStats(dynamicEntries, state.currentType);
    emit(state.copyWith(entries: dynamicEntries, myRank: rank, myBalance: balance));
  }

  Future<List<LeaderboardEntry>> _fetchDynamicEntries(
    LeaderboardType type,
    LeaderboardTimeframe timeframe,
  ) async {
    try {
      // Direct dynamic query on Supabase profiles sorted by real live wealth / charm
      final isCharm = type == LeaderboardType.charm;
      final sortColumn = isCharm ? 'gem_balance' : 'coin_balance';

      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .order(sortColumn, ascending: false)
          .limit(50);

      if (response.isNotEmpty) {
        int currentRank = 1;
        return (response as List).map((row) {
          final score = (row[sortColumn] as num?)?.toDouble() ?? 0.0;
          String formatted;
          if (score >= 1000000) {
            formatted = '${(score / 1000000).toStringAsFixed(2)}M';
          } else if (score >= 1000) {
            formatted = '${(score / 1000).toStringAsFixed(1)}K';
          } else {
            formatted = score.toStringAsFixed(0);
          }

          final rank = currentRank++;
          final isVip = row['is_vip'] as bool? ?? false;
          final userName = (row['nickname'] as String?)?.isNotEmpty == true
              ? row['nickname'] as String
              : 'Royal User';

          return LeaderboardEntry(
            rank: rank,
            username: userName,
            flagEmoji: row['country_flag'] as String? ?? '🇧🇩',
            gender: row['gender']?.toString().split(' ').first ?? '♂',
            age: (row['age'] as num?)?.toInt() ?? 20,
            level: (row['level'] as num?)?.toInt() ?? 1,
            levelType: 'LV',
            amount: score,
            amountFormatted: formatted,
            isGems: isCharm,
            usdEquivalent: score * 0.0001,
            avatarUrl: (row['avatar_url'] as String?)?.isNotEmpty == true
                ? row['avatar_url'] as String
                : null,
            isVip: isVip,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[LeaderboardBloc] Supabase fetch error: $e');
    }

    return const [];
  }

  (int, String) _calculateMyStats(List<LeaderboardEntry> entries, LeaderboardType type) {
    final currentUserId = AuthSessionManager.currentUserId;
    if (currentUserId == null || currentUserId.isEmpty || entries.isEmpty) {
      return (1, type == LeaderboardType.charm ? '0 💎' : '0 🪙');
    }

    final isCharm = type == LeaderboardType.charm;
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].username.contains(currentUserId.substring(0, currentUserId.length.clamp(0, 8)))) {
        return (i + 1, '${entries[i].amountFormatted} ${isCharm ? '💎' : '🪙'}');
      }
    }

    return (entries.length + 1, '16.8K ${isCharm ? '💎' : '🪙'}');
  }

  void _onToggleAnonymous(ToggleAnonymousEvent event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(isAnonymous: !state.isAnonymous));
  }
}
