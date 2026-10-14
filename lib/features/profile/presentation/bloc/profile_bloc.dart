import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(_createInitialState()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<RechargeCoinsEvent>(_onRechargeCoins);
    on<WithdrawGemsEvent>(_onWithdrawGems);

    // Initial fetch from Supabase
    add(LoadUserProfileEvent());
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // 1. Fetch Profile from Supabase
      final profileRes = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', '30961573')
          .maybeSingle();

      UserProfile currentProfile = state.profile;
      if (profileRes != null) {
        currentProfile = UserProfile(
          userId: profileRes['id'] as String? ?? '30961573',
          nickname: profileRes['nickname'] as String? ?? 'User30961573',
          avatarUrl: profileRes['avatar_url'] as String? ?? '',
          country: profileRes['country'] as String? ?? 'Bangladesh',
          gender: profileRes['gender'] as String? ?? '♂ 19',
          age: (profileRes['age'] as num?)?.toInt() ?? 19,
          level: (profileRes['level'] as num?)?.toInt() ?? 1,
          isVip: profileRes['is_vip'] as bool? ?? true,
          friendsCount: (profileRes['friends_count'] as num?)?.toInt() ?? 0,
          followingCount: (profileRes['following_count'] as num?)?.toInt() ?? 0,
          fansCount: (profileRes['fans_count'] as num?)?.toInt() ?? 0,
          visitorsCount: (profileRes['visitors_count'] as num?)?.toInt() ?? 0,
          gemBalance: (profileRes['gem_balance'] as num?)?.toDouble() ?? 0.0,
          coinBalance: (profileRes['coin_balance'] as num?)?.toDouble() ?? 161480.0,
        );
      }

      // 2. Fetch latest withdrawal ticker text
      String ticker = state.recentWithdrawalText;
      final withdrawalRes = await SupabaseConfig.client
          .from('withdrawals')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (withdrawalRes != null) {
        final user = withdrawalRes['user_name'] ?? 'User';
        final amt = withdrawalRes['amount'] ?? '10.0';
        ticker = '$user withdrew \$$amt';
      }

      emit(state.copyWith(profile: currentProfile, recentWithdrawalText: ticker));
    } catch (e) {
      debugPrint('ProfileBloc Supabase fetch error: $e');
    }
  }

  Future<void> _onRechargeCoins(
    RechargeCoinsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final newBalance = state.profile.coinBalance + event.amount;
    final updatedProfile = UserProfile(
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
      gemBalance: state.profile.gemBalance,
      coinBalance: newBalance,
    );
    emit(state.copyWith(profile: updatedProfile));

    try {
      await SupabaseConfig.client.from('profiles').update({
        'coin_balance': newBalance,
      }).eq('id', state.profile.userId);
    } catch (e) {
      debugPrint('ProfileBloc Supabase update error: $e');
    }
  }

  Future<void> _onWithdrawGems(
    WithdrawGemsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile.gemBalance >= event.gems) {
      final newGems = state.profile.gemBalance - event.gems;
      final updatedProfile = UserProfile(
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
        gemBalance: newGems,
        coinBalance: state.profile.coinBalance,
      );
      emit(state.copyWith(profile: updatedProfile));

      try {
        await SupabaseConfig.client.from('profiles').update({
          'gem_balance': newGems,
        }).eq('id', state.profile.userId);

        // Record withdrawal request in Supabase
        await SupabaseConfig.client.from('withdrawals').insert({
          'id': 'WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'user_id': state.profile.userId,
          'user_name': state.profile.nickname,
          'user_avatar': state.profile.avatarUrl,
          'gateway': 'bKash',
          'amount': event.gems / 1000,
          'gems': event.gems.toInt(),
          'status': 'Pending',
        });
      } catch (e) {
        debugPrint('ProfileBloc Supabase withdrawal error: $e');
      }
    }
  }

  static ProfileState _createInitialState() {
    const profile = UserProfile(
      userId: '30961573',
      nickname: 'User30961573',
      avatarUrl: '',
      country: 'Bangladesh',
      gender: '♂ 19',
      age: 19,
      level: 1,
      isVip: true,
      friendsCount: 0,
      followingCount: 0,
      fansCount: 0,
      visitorsCount: 0,
      gemBalance: 0.0,
      coinBalance: 161480.0, // 161.48K
    );

    return const ProfileState(
      profile: profile,
      recentWithdrawalText: 'yanboyy withdrew \$10.0',
    );
  }
}
