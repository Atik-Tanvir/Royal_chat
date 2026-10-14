import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboardEvent extends LeaderboardEvent {}

class ChangeLeaderboardTypeEvent extends LeaderboardEvent {
  final LeaderboardType type;

  const ChangeLeaderboardTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class ChangeLeaderboardTimeframeEvent extends LeaderboardEvent {
  final LeaderboardTimeframe timeframe;

  const ChangeLeaderboardTimeframeEvent(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}

class ToggleAnonymousEvent extends LeaderboardEvent {}
