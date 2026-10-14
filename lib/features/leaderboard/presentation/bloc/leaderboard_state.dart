import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardState extends Equatable {
  final LeaderboardType currentType;
  final LeaderboardTimeframe currentTimeframe;
  final List<LeaderboardEntry> entries;
  final bool isAnonymous;
  final int myRank;
  final String myBalance;

  const LeaderboardState({
    required this.currentType,
    required this.currentTimeframe,
    required this.entries,
    required this.isAnonymous,
    required this.myRank,
    required this.myBalance,
  });

  LeaderboardState copyWith({
    LeaderboardType? currentType,
    LeaderboardTimeframe? currentTimeframe,
    List<LeaderboardEntry>? entries,
    bool? isAnonymous,
    int? myRank,
    String? myBalance,
  }) {
    return LeaderboardState(
      currentType: currentType ?? this.currentType,
      currentTimeframe: currentTimeframe ?? this.currentTimeframe,
      entries: entries ?? this.entries,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      myRank: myRank ?? this.myRank,
      myBalance: myBalance ?? this.myBalance,
    );
  }

  @override
  List<Object?> get props => [
        currentType,
        currentTimeframe,
        entries,
        isAnonymous,
        myRank,
        myBalance,
      ];
}
