import '../entities/bucket_game_item.dart';
import '../entities/games_control_config.dart';
import '../entities/rewarded_ad_item.dart';

/// Shared Clean Architecture domain repository contract for games
/// (Bucket Spin, Color Spin, 7 Up 7 Down, Balloon Sky) and Admin controls.
abstract class BucketGameRepository {
  /// Updates the user's persisted coin balance in backend storage.
  Future<void> updateUserCoinBalance({
    required String userId,
    required double newBalance,
  });

  /// Records a winning game payout transaction in the user's wallet history.
  Future<void> recordGameWinTransaction({
    required String userId,
    required String title,
    required int winCoins,
    required String gateway,
  });

  /// Fetches live Admin-controlled Rewarded Ads configuration.
  Future<RewardedAdsConfig> fetchActiveRewardedAds();

  /// Fetches live Admin-controlled Games Control configuration
  /// (per-game multipliers, min/max bet limits, round timers, freeze toggles).
  Future<GamesControlConfig> fetchGamesControlConfig();

  /// Records a completed Rewarded Ad coin credit in the user's wallet history.
  Future<void> recordAdRewardTransaction({
    required String userId,
    required RewardedAdItem ad,
  });

  /// Subscribes to live group bets for a specific game & group channel.
  void subscribeToGroupRoom({
    required String channelName,
    required void Function(GroupBetRecord record, int round) onRemoteBetReceived,
  });

  /// Broadcasts the current user's bet to other players in the same group room.
  Future<void> broadcastGroupBet({
    required String channelName,
    required GroupBetRecord bet,
    required int round,
  });

  /// Unsubscribes from any active group room channel.
  Future<void> unsubscribeGroupRoom();
}
