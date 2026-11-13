import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/wallet_transaction_service.dart';
import '../../../profile/domain/entities/wallet_transaction.dart';
import '../../domain/entities/bucket_game_item.dart';
import '../../domain/entities/games_control_config.dart';
import '../../domain/entities/rewarded_ad_item.dart';
import '../../domain/repositories/bucket_game_repository.dart';

/// Supabase + Admin Ads API + WalletTransactionService implementation of [BucketGameRepository].
class BucketGameRepositoryImpl implements BucketGameRepository {
  RealtimeChannel? _groupChannel;

  static const RewardedAdsConfig _fallbackConfig = RewardedAdsConfig(
    adsEnabled: true,
    activeAds: [
      RewardedAdItem(
        id: 'ad_admob_1',
        title: 'Google AdMob Rewarded Video',
        network: 'Google AdMob',
        description: 'Watch this short sponsored video to earn free game coins.',
        imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
        targetUrl: 'https://admob.google.com',
        rewardCoins: 500,
        durationSeconds: 5,
        isEnabled: true,
      ),
    ],
  );

  @override
  Future<void> updateUserCoinBalance({
    required String userId,
    required double newBalance,
  }) async {
    try {
      await SupabaseConfig.client
          .from('profiles')
          .update({'coin_balance': newBalance})
          .eq('id', userId);
    } catch (e) {
      debugPrint('[BucketGameRepo] updateUserCoinBalance error: $e');
    }
  }

  @override
  Future<void> recordGameWinTransaction({
    required String userId,
    required String title,
    required int winCoins,
    required String gateway,
  }) async {
    try {
      final tx = WalletTransaction(
        id: 'BGW-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: 'conversion',
        title: title,
        amount: winCoins.toDouble(),
        currency: 'coin',
        status: 'Completed',
        gateway: gateway,
        createdAt: DateTime.now(),
      );
      await WalletTransactionService.recordTransaction(tx);
    } catch (e) {
      debugPrint('[BucketGameRepo] recordGameWinTransaction error: $e');
    }
  }

  Future<dynamic> _fetchFirstAvailableJson(String apiPath) async {
    final cacheBust = DateTime.now().millisecondsSinceEpoch;
    final pathWithQuery = '$apiPath?t=$cacheBust';
    final endpoints = <Uri>[
      if (kIsWeb) Uri.base.resolve(pathWithQuery),
      Uri.parse('http://localhost:4000$pathWithQuery'),
      if (!kIsWeb) Uri.parse('http://10.0.2.2:4000$pathWithQuery'),
    ];

    for (final uri in endpoints) {
      try {
        final response = await http
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      } catch (_) {
        // Try next endpoint
      }
    }
    return null;
  }

  @override
  Future<RewardedAdsConfig> fetchActiveRewardedAds() async {
    final json = await _fetchFirstAvailableJson('/api/ads-config');
    final parsed = _parseConfigJson(json);
    if (parsed != null) return parsed;

    try {
      final row = await SupabaseConfig.client
          .from('system_messages')
          .select('content')
          .eq('type', 'rewarded_ad_config')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row != null && row['content'] != null) {
        final remoteParsed = _parseConfigJson(jsonDecode(row['content'].toString()));
        if (remoteParsed != null) return remoteParsed;
      }
    } catch (e) {
      debugPrint('[BucketGameRepo] Supabase ads config fallback error: $e');
    }

    return _fallbackConfig;
  }

  @override
  Future<GamesControlConfig> fetchGamesControlConfig() async {
    final json = await _fetchFirstAvailableJson('/api/games-config');
    if (json is Map<String, dynamic>) {
      return GamesControlConfig.fromJson(json);
    }

    try {
      final row = await SupabaseConfig.client
          .from('system_messages')
          .select('content')
          .eq('type', 'games_control_config')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row != null && row['content'] != null) {
        final decoded = jsonDecode(row['content'].toString());
        if (decoded is Map<String, dynamic>) {
          return GamesControlConfig.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('[BucketGameRepo] Supabase games config fallback error: $e');
    }

    return GamesControlConfig.defaults;
  }

  RewardedAdsConfig? _parseConfigJson(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final adsEnabled = data['adsEnabled'] as bool? ?? true;
    final rawList = data['rewardedAds'];
    if (rawList is! List) return null;

    final allAds = rawList
        .whereType<Map<String, dynamic>>()
        .map(RewardedAdItem.fromJson)
        .toList();

    final enabledAds = adsEnabled
        ? allAds.where((ad) => ad.isEnabled).toList()
        : <RewardedAdItem>[];

    return RewardedAdsConfig(
      adsEnabled: adsEnabled,
      activeAds: enabledAds,
    );
  }

  @override
  Future<void> recordAdRewardTransaction({
    required String userId,
    required RewardedAdItem ad,
  }) async {
    try {
      final tx = WalletTransaction(
        id: 'ADR-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: 'conversion',
        title: 'Watched Ad Reward (${ad.network})',
        amount: ad.rewardCoins.toDouble(),
        currency: 'coin',
        status: 'Completed',
        gateway: 'Rewarded Ad',
        createdAt: DateTime.now(),
      );
      await WalletTransactionService.recordTransaction(tx);
    } catch (e) {
      debugPrint('[BucketGameRepo] recordAdRewardTransaction error: $e');
    }
  }

  @override
  void subscribeToGroupRoom({
    required String channelName,
    required void Function(GroupBetRecord record, int round) onRemoteBetReceived,
  }) {
    unsubscribeGroupRoom();
    try {
      _groupChannel = SupabaseConfig.client
          .channel(channelName)
          .onBroadcast(
            event: 'group_bet',
            callback: (payload) {
              final senderId = payload['userId']?.toString() ?? '';
              final myId = AuthSessionManager.currentUserId ?? 'local_guest';
              if (senderId == myId) return;

              final round = (payload['round'] as num?)?.toInt() ?? 0;
              final itemId = payload['itemId']?.toString() ?? '';
              final amount = (payload['amount'] as num?)?.toInt() ?? 0;
              final userName = payload['userName']?.toString() ?? 'Player';
              if (itemId.isEmpty || amount <= 0) return;

              onRemoteBetReceived(
                GroupBetRecord(
                  userId: senderId,
                  userName: userName,
                  itemId: itemId,
                  amount: amount,
                  isSelf: false,
                ),
                round,
              );
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[BucketGameRepo] subscribeToGroupRoom error: $e');
    }
  }

  @override
  Future<void> broadcastGroupBet({
    required String channelName,
    required GroupBetRecord bet,
    required int round,
  }) async {
    if (_groupChannel == null) return;
    try {
      await _groupChannel!.sendBroadcastMessage(
        event: 'group_bet',
        payload: {
          'userId': bet.userId,
          'userName': bet.userName,
          'itemId': bet.itemId,
          'amount': bet.amount,
          'round': round,
        },
      );
    } catch (e) {
      debugPrint('[BucketGameRepo] broadcastGroupBet error: $e');
    }
  }

  @override
  Future<void> unsubscribeGroupRoom() async {
    try {
      await _groupChannel?.unsubscribe();
      _groupChannel = null;
    } catch (e) {
      debugPrint('[BucketGameRepo] unsubscribeGroupRoom error: $e');
    }
  }
}
