import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc()
      : super(
          LeaderboardState(
            currentType: LeaderboardType.wealth,
            currentTimeframe: LeaderboardTimeframe.daily,
            entries: _getWealthEntries(),
            isAnonymous: false,
            myRank: 99,
            myBalance: '161.48K',
          ),
        ) {
    on<ChangeLeaderboardTypeEvent>(_onChangeType);
    on<ChangeLeaderboardTimeframeEvent>(_onChangeTimeframe);
    on<ToggleAnonymousEvent>(_onToggleAnonymous);
  }

  void _onChangeType(ChangeLeaderboardTypeEvent event, Emitter<LeaderboardState> emit) {
    List<LeaderboardEntry> newEntries;
    switch (event.type) {
      case LeaderboardType.wealth:
        newEntries = _getWealthEntries();
        break;
      case LeaderboardType.game:
        newEntries = _getGameEntries();
        break;
      case LeaderboardType.charm:
        newEntries = _getCharmEntries();
        break;
      case LeaderboardType.invitation:
        newEntries = _getInvitationEntries();
        break;
    }

    emit(state.copyWith(
      currentType: event.type,
      entries: newEntries,
    ));
  }

  void _onChangeTimeframe(ChangeLeaderboardTimeframeEvent event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(currentTimeframe: event.timeframe));
  }

  void _onToggleAnonymous(ToggleAnonymousEvent event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(isAnonymous: !state.isAnonymous));
  }

  static List<LeaderboardEntry> _getWealthEntries() {
    return const [
      LeaderboardEntry(
        rank: 1,
        username: '🦅H U N T E R🦅',
        flagEmoji: '🇺🇸',
        gender: '♂',
        age: 19,
        level: 3,
        amount: 348.29,
        amountFormatted: '348.29M',
        usdEquivalent: 696,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 2,
        username: 'User32653961',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 19,
        level: 4,
        amount: 250.31,
        amountFormatted: '250.31M',
        usdEquivalent: 500,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 3,
        username: '💕⚜️Imran⚜️',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 35,
        level: 7,
        amount: 202.72,
        amountFormatted: '202.72M',
        usdEquivalent: 405,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 4,
        username: 'Gentle Swan4382',
        flagEmoji: '🇮🇩',
        gender: '♂',
        age: 18,
        level: 1,
        amount: 174.57,
        amountFormatted: '174.57M',
        usdEquivalent: 349,
      ),
      LeaderboardEntry(
        rank: 5,
        username: '💚HEART❤️9175',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 20,
        level: 3,
        amount: 169.8,
        amountFormatted: '169.8M',
        usdEquivalent: 339,
      ),
      LeaderboardEntry(
        rank: 6,
        username: 'mawaliii',
        flagEmoji: '🇦🇪',
        gender: '♂',
        age: 26,
        level: 7,
        amount: 161.63,
        amountFormatted: '161.63M',
        usdEquivalent: 323,
      ),
      LeaderboardEntry(
        rank: 7,
        username: 'Danirajpot',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 19,
        level: 2,
        amount: 157.79,
        amountFormatted: '157.79M',
        usdEquivalent: 315,
      ),
      LeaderboardEntry(
        rank: 8,
        username: '🌻KAGAYAKU🌻',
        flagEmoji: '🇧🇩',
        gender: '♂',
        age: 27,
        level: 8,
        amount: 151.61,
        amountFormatted: '151.61M',
        usdEquivalent: 303,
      ),
      LeaderboardEntry(
        rank: 9,
        username: 'nick8754',
        flagEmoji: '🇳🇵',
        gender: '♂',
        age: 32,
        level: 7,
        amount: 148.45,
        amountFormatted: '148.45M',
        usdEquivalent: 296,
      ),
      LeaderboardEntry(
        rank: 10,
        username: 'F I G H T E R ☠️',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 19,
        level: 3,
        amount: 145.8,
        amountFormatted: '145.8M',
        usdEquivalent: 291,
      ),
    ];
  }

  static List<LeaderboardEntry> _getGameEntries() {
    return const [
      LeaderboardEntry(
        rank: 1,
        username: '🌻KAGAYAKU🌻',
        flagEmoji: '🇧🇩',
        gender: '♂',
        age: 27,
        level: 8,
        amount: 130.62,
        amountFormatted: '130.62M',
        usdEquivalent: 261,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 2,
        username: '🦅MURSHID🦅',
        flagEmoji: '🇦🇪',
        gender: '♂',
        age: 26,
        level: 8,
        amount: 124.51,
        amountFormatted: '124.51M',
        usdEquivalent: 249,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 3,
        username: 'Typing.',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 24,
        level: 6,
        amount: 107.91,
        amountFormatted: '107.91M',
        usdEquivalent: 215,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 4,
        username: '👑ROCKSTAR👑',
        flagEmoji: '🇧🇩',
        gender: '♂',
        age: 27,
        level: 6,
        amount: 87.47,
        amountFormatted: '87.47M',
        usdEquivalent: 174,
      ),
      LeaderboardEntry(
        rank: 5,
        username: 'HappyBirthday TS',
        flagEmoji: '🇳🇬',
        gender: '♂',
        age: 19,
        level: 8,
        amount: 53.13,
        amountFormatted: '53.13M',
        usdEquivalent: 106,
      ),
    ];
  }

  static List<LeaderboardEntry> _getCharmEntries() {
    return const [
      LeaderboardEntry(
        rank: 1,
        username: 'Libra❤️4570',
        flagEmoji: '🇵🇭',
        gender: '♀',
        age: 37,
        level: 6,
        amount: 699.86,
        amountFormatted: '699.86K',
        isGems: true,
        usdEquivalent: 69,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 2,
        username: 'Diane ❥',
        flagEmoji: '🇵🇭',
        gender: '♀',
        age: 27,
        level: 6,
        amount: 454.38,
        amountFormatted: '454.38K',
        isGems: true,
        usdEquivalent: 45,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 3,
        username: 'Nadar khan6723',
        flagEmoji: '🇦🇹',
        gender: '♀',
        age: 19,
        level: 8,
        amount: 403.68,
        amountFormatted: '403.68K',
        isGems: true,
        usdEquivalent: 40,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 4,
        username: 'Eyaッ',
        flagEmoji: '🇵🇭',
        gender: '♀',
        age: 20,
        level: 5,
        amount: 314.13,
        amountFormatted: '314.13K',
        isGems: true,
        usdEquivalent: 31,
      ),
      LeaderboardEntry(
        rank: 5,
        username: '𝓙ASMINE😊',
        flagEmoji: '🇧🇩',
        gender: '♀',
        age: 19,
        level: 8,
        amount: 290.13,
        amountFormatted: '290.13K',
        isGems: true,
        usdEquivalent: 29,
      ),
    ];
  }

  static List<LeaderboardEntry> _getInvitationEntries() {
    return const [
      LeaderboardEntry(
        rank: 1,
        username: 'TopReferralPro',
        flagEmoji: '🇧🇩',
        gender: '♂',
        age: 24,
        level: 9,
        amount: 88.5,
        amountFormatted: '88.50M',
        usdEquivalent: 177,
        isVip: true,
      ),
      LeaderboardEntry(
        rank: 2,
        username: 'InviteMaster',
        flagEmoji: '🇵🇰',
        gender: '♂',
        age: 22,
        level: 7,
        amount: 62.1,
        amountFormatted: '62.10M',
        usdEquivalent: 124,
        isVip: true,
      ),
    ];
  }
}
