import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/wallet_transaction_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/wallet_transaction.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  RealtimeChannel? _profileChannel;
  RealtimeChannel? _withdrawalsChannel;

  ProfileBloc() : super(_createInitialState()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<RechargeCoinsEvent>(_onRechargeCoins);
    on<WithdrawGemsEvent>(_onWithdrawGems);
    on<ConvertGemsToCoinsEvent>(_onConvertGemsToCoins);
    on<ClaimDailyRewardEvent>(_onClaimDailyReward);
    on<ProfileBalancesUpdatedFromRealtimeEvent>(_onProfileBalancesUpdatedFromRealtime);
    on<UpdateProfileDetailsEvent>(_onUpdateProfileDetails);
    on<SignOutEvent>(_onSignOut);

    // Initial dynamic fetch from Supabase
    add(LoadUserProfileEvent());
  }

  @override
  Future<void> close() {
    _profileChannel?.unsubscribe();
    _withdrawalsChannel?.unsubscribe();
    return super.close();
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentUserId = AuthSessionManager.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        return;
      }

      final user = SupabaseConfig.client.auth.currentUser;
      final defaultName = AuthSessionManager.currentUserName ??
          user?.userMetadata?['full_name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          user?.email?.split('@').first ??
          'RoyalUser';
      final defaultAvatar = AuthSessionManager.currentUserAvatar ??
          user?.userMetadata?['avatar_url'] as String? ?? '';

      // 1. Fetch Profile from Supabase
      var profileRes = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .maybeSingle();

      // If profile doesn't exist yet, insert a dynamic new profile for the user
      if (profileRes == null) {
        await SupabaseConfig.client.from('profiles').insert({
          'id': currentUserId,
          'nickname': defaultName,
          'avatar_url': defaultAvatar,
          'country': 'Bangladesh',
          'country_flag': '🇧🇩',
          'gender': '♂ 20',
          'age': 20,
          'level': 1,
          'is_vip': false,
          'coin_balance': 5000,
          'gem_balance': 0,
          'friends_count': 0,
          'following_count': 0,
          'fans_count': 0,
          'visitors_count': 0,
          'is_online': true,
        });

        profileRes = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', currentUserId)
            .maybeSingle();
      }

      UserProfile currentProfile = state.profile;
      if (profileRes != null) {
        currentProfile = UserProfile(
          userId: profileRes['id'] as String? ?? currentUserId,
          nickname: profileRes['nickname'] as String? ?? defaultName,
          avatarUrl: profileRes['avatar_url'] as String? ?? defaultAvatar,
          country: profileRes['country'] as String? ?? 'Bangladesh',
          gender: profileRes['gender'] as String? ?? '♂ 20',
          age: (profileRes['age'] as num?)?.toInt() ?? 20,
          level: (profileRes['level'] as num?)?.toInt() ?? 1,
          isVip: profileRes['is_vip'] as bool? ?? false,
          friendsCount: (profileRes['friends_count'] as num?)?.toInt() ?? 0,
          followingCount: (profileRes['following_count'] as num?)?.toInt() ?? 0,
          fansCount: (profileRes['fans_count'] as num?)?.toInt() ?? 0,
          visitorsCount: (profileRes['visitors_count'] as num?)?.toInt() ?? 0,
          gemBalance: (profileRes['gem_balance'] as num?)?.toDouble() ?? 0.0,
          coinBalance: (profileRes['coin_balance'] as num?)?.toDouble() ?? 0.0,
        );
      }

      // 2. Fetch latest withdrawal ticker text from Supabase withdrawals table
      String ticker = 'Welcome to Royal Chat Live';
      final withdrawalRes = await SupabaseConfig.client
          .from('withdrawals')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (withdrawalRes != null) {
        final u = withdrawalRes['user_name'] ?? 'User';
        final amt = withdrawalRes['amount'] ?? '10.0';
        ticker = '$u withdrew \$$amt';
      }

      emit(state.copyWith(profile: currentProfile, recentWithdrawalText: ticker));

      // 3. Subscribe to Realtime Supabase updates on user's profile
      _subscribeToRealtime(currentUserId);

      // 4. Load wallet transactions
      add(LoadTransactionsEvent());
    } catch (e) {
      debugPrint('[ProfileBloc] Supabase fetch error: $e');
    }
  }

  void _subscribeToRealtime(String userId) {
    if (_profileChannel != null) return;

    try {
      _profileChannel = SupabaseConfig.client
          .channel('public:profiles:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: userId,
            ),
            callback: (payload) {
              final newRecord = payload.newRecord;
              if (newRecord.isNotEmpty) {
                final coins = (newRecord['coin_balance'] as num?)?.toDouble();
                final gems = (newRecord['gem_balance'] as num?)?.toDouble();
                add(ProfileBalancesUpdatedFromRealtimeEvent(
                  coinBalance: coins,
                  gemBalance: gems,
                ));
              }
            },
          )
          .subscribe();

      _withdrawalsChannel = SupabaseConfig.client
          .channel('public:withdrawals:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'withdrawals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (_) {
              add(LoadTransactionsEvent());
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[ProfileBloc] Realtime subscription error: $e');
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final userId = state.profile.userId;
    if (userId.isEmpty) return;

    try {
      final txList = await WalletTransactionService.getTransactions(userId);
      emit(state.copyWith(transactions: txList));
    } catch (e) {
      debugPrint('[ProfileBloc] Load transactions error: $e');
    }
  }

  Future<void> _onRechargeCoins(
    RechargeCoinsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final newBalance = state.profile.coinBalance + event.amount;
    final updatedProfile = _cloneProfileWith(coinBalance: newBalance);
    emit(state.copyWith(profile: updatedProfile));

    try {
      await SupabaseConfig.client.from('profiles').update({
        'coin_balance': newBalance,
      }).eq('id', state.profile.userId);

      // Record transaction
      final tx = WalletTransaction(
        id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
        userId: state.profile.userId,
        type: 'recharge',
        title: event.packageTitle,
        amount: event.amount,
        currency: 'coin',
        status: 'Completed',
        gateway: event.gateway,
        createdAt: DateTime.now(),
      );
      await WalletTransactionService.recordTransaction(tx);
      add(LoadTransactionsEvent());
    } catch (e) {
      debugPrint('[ProfileBloc] Recharge error: $e');
    }
  }

  Future<void> _onWithdrawGems(
    WithdrawGemsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile.gemBalance >= event.gems) {
      final newGems = state.profile.gemBalance - event.gems;
      final updatedProfile = _cloneProfileWith(gemBalance: newGems);
      emit(state.copyWith(profile: updatedProfile));

      try {
        await SupabaseConfig.client.from('profiles').update({
          'gem_balance': newGems,
        }).eq('id', state.profile.userId);

        final withdrawalId = 'WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        final gatewayInfo = event.accountNumber.isNotEmpty
            ? '${event.gateway} (${event.accountNumber})'
            : event.gateway;

        await SupabaseConfig.client.from('withdrawals').insert({
          'id': withdrawalId,
          'user_id': state.profile.userId,
          'user_name': state.profile.nickname,
          'user_avatar': state.profile.avatarUrl,
          'gateway': gatewayInfo,
          'amount': event.gems / 1000,
          'gems': event.gems.toInt(),
          'status': 'Pending',
        });

        final tx = WalletTransaction(
          id: withdrawalId,
          userId: state.profile.userId,
          type: 'withdrawal',
          title: 'Withdrawal to $gatewayInfo',
          amount: event.gems,
          currency: 'gem',
          status: 'Pending',
          gateway: event.gateway,
          createdAt: DateTime.now(),
        );
        await WalletTransactionService.recordTransaction(tx);
        add(LoadTransactionsEvent());
      } catch (e) {
        debugPrint('[ProfileBloc] Withdrawal error: $e');
      }
    }
  }

  Future<void> _onConvertGemsToCoins(
    ConvertGemsToCoinsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile.gemBalance >= event.gems) {
      final newGems = state.profile.gemBalance - event.gems;
      final newCoins = state.profile.coinBalance + event.coins;
      final updatedProfile = _cloneProfileWith(
        gemBalance: newGems,
        coinBalance: newCoins,
      );
      emit(state.copyWith(profile: updatedProfile));

      try {
        await SupabaseConfig.client.from('profiles').update({
          'gem_balance': newGems,
          'coin_balance': newCoins,
        }).eq('id', state.profile.userId);

        final tx = WalletTransaction(
          id: 'EX-${DateTime.now().millisecondsSinceEpoch}',
          userId: state.profile.userId,
          type: 'conversion',
          title: 'Exchange ${event.gems.toInt()} 💎 to Coins',
          amount: event.coins,
          currency: 'coin',
          status: 'Completed',
          gateway: 'Diamond Converter',
          createdAt: DateTime.now(),
        );
        await WalletTransactionService.recordTransaction(tx);
        add(LoadTransactionsEvent());
      } catch (e) {
        debugPrint('[ProfileBloc] Conversion error: $e');
      }
    }
  }

  Future<void> _onClaimDailyReward(
    ClaimDailyRewardEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final newCoins = state.profile.coinBalance + event.rewardCoins;
    final updatedProfile = _cloneProfileWith(coinBalance: newCoins);
    emit(state.copyWith(profile: updatedProfile));

    try {
      await SupabaseConfig.client.from('profiles').update({
        'coin_balance': newCoins,
      }).eq('id', state.profile.userId);

      final tx = WalletTransaction(
        id: 'RW-${DateTime.now().millisecondsSinceEpoch}',
        userId: state.profile.userId,
        type: 'daily_reward',
        title: 'Day ${event.dayNumber} Sign-in Reward',
        amount: event.rewardCoins,
        currency: 'coin',
        status: 'Completed',
        gateway: 'Daily Task',
        createdAt: DateTime.now(),
      );
      await WalletTransactionService.recordTransaction(tx);
      add(LoadTransactionsEvent());
    } catch (e) {
      debugPrint('[ProfileBloc] Daily reward error: $e');
    }
  }

  void _onProfileBalancesUpdatedFromRealtime(
    ProfileBalancesUpdatedFromRealtimeEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (event.coinBalance == null && event.gemBalance == null) return;
    final updatedProfile = _cloneProfileWith(
      coinBalance: event.coinBalance ?? state.profile.coinBalance,
      gemBalance: event.gemBalance ?? state.profile.gemBalance,
    );
    emit(state.copyWith(profile: updatedProfile));
  }

  Future<void> _onUpdateProfileDetails(
    UpdateProfileDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final updatedProfile = UserProfile(
      userId: state.profile.userId,
      nickname: event.nickname ?? state.profile.nickname,
      avatarUrl: event.avatarUrl ?? state.profile.avatarUrl,
      country: event.country ?? state.profile.country,
      gender: event.gender ?? state.profile.gender,
      age: event.age ?? state.profile.age,
      level: state.profile.level,
      isVip: state.profile.isVip,
      friendsCount: state.profile.friendsCount,
      followingCount: state.profile.followingCount,
      fansCount: state.profile.fansCount,
      visitorsCount: state.profile.visitorsCount,
      gemBalance: state.profile.gemBalance,
      coinBalance: state.profile.coinBalance,
    );

    emit(state.copyWith(profile: updatedProfile));

    try {
      final updates = <String, dynamic>{};
      if (event.nickname != null) updates['nickname'] = event.nickname;
      if (event.avatarUrl != null) updates['avatar_url'] = event.avatarUrl;
      if (event.country != null) updates['country'] = event.country;
      if (event.gender != null) updates['gender'] = event.gender;
      if (event.age != null) updates['age'] = event.age;

      if (updates.isNotEmpty) {
        await SupabaseConfig.client
            .from('profiles')
            .update(updates)
            .eq('id', state.profile.userId);
      }
    } catch (e) {
      debugPrint('[ProfileBloc] Supabase update profile error: $e');
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    _profileChannel?.unsubscribe();
    _withdrawalsChannel?.unsubscribe();
    _profileChannel = null;
    _withdrawalsChannel = null;
    await AuthSessionManager.signOut();
    emit(_createInitialState());
  }

  UserProfile _cloneProfileWith({
    double? coinBalance,
    double? gemBalance,
  }) {
    return UserProfile(
      userId: state.profile.userId,
      nickname: state.profile.nickname,
      avatarUrl: state.profile.avatarUrl,
      country: state.profile.country,
      gender: state.profile.gender,
      age: state.profile.age,
      level: state.profile.level,
      isVip: state.profile.isVip,
      friendsCount: state.profile.friendsCount,
      followingCount: state.profile.followingCount,
      fansCount: state.profile.fansCount,
      visitorsCount: state.profile.visitorsCount,
      gemBalance: gemBalance ?? state.profile.gemBalance,
      coinBalance: coinBalance ?? state.profile.coinBalance,
    );
  }

  static ProfileState _createInitialState() {
    final activeId = AuthSessionManager.currentUserId ?? '';
    final profile = UserProfile(
      userId: activeId,
      nickname: activeId.isNotEmpty ? activeId : 'Royal User',
      avatarUrl: '',
      country: 'Bangladesh',
      gender: '♂ 20',
      age: 20,
      level: 1,
      isVip: false,
      friendsCount: 0,
      followingCount: 0,
      fansCount: 0,
      visitorsCount: 0,
      gemBalance: 0.0,
      coinBalance: 5000.0,
    );
    return ProfileState(profile: profile);
  }
}
