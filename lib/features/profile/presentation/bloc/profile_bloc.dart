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
    on<UpdateProfileDetailsEvent>(_onUpdateProfileDetails);

    // Initial dynamic fetch from Supabase
    add(LoadUserProfileEvent());
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      final currentUserId = user?.id ?? '30961573';
      final defaultName = user?.userMetadata?['full_name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          user?.email?.split('@').first ??
          'RoyalUser';
      final defaultAvatar = user?.userMetadata?['avatar_url'] as String? ?? '';

      // 1. Fetch Profile from Supabase
      var profileRes = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .maybeSingle();

      // If profile doesn't exist yet, insert a dynamic new profile for the user
      if (profileRes == null) {
        await SupabaseConfig.client.from('profiles').upsert({
          'id': currentUserId,
          'nickname': defaultName,
          'avatar_url': defaultAvatar,
          'country': 'Bangladesh',
          'country_flag': '🇧🇩',
          'gender': '♂ 19',
          'age': 19,
          'level': 1,
          'is_vip': true,
          'coin_balance': 161480,
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

      // 2. Fetch latest withdrawal ticker text from Supabase withdrawals table
      String ticker = state.recentWithdrawalText;
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

        // Record live withdrawal request in Supabase withdrawals table
        final gatewayInfo = event.accountNumber.isNotEmpty
            ? '${event.gateway} (${event.accountNumber})'
            : event.gateway;

        await SupabaseConfig.client.from('withdrawals').insert({
          'id': 'WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'user_id': state.profile.userId,
          'user_name': state.profile.nickname,
          'user_avatar': state.profile.avatarUrl,
          'gateway': gatewayInfo,
          'amount': event.gems / 1000,
          'gems': event.gems.toInt(),
          'status': 'Pending',
        });
      } catch (e) {
        debugPrint('ProfileBloc Supabase withdrawal error: $e');
      }
    }
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
      debugPrint('ProfileBloc Supabase update profile error: $e');
    }
  }

  static ProfileState _createInitialState() {
    final user = SupabaseConfig.client.auth.currentUser;
    final defaultName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.email?.split('@').first ??
        'RoyalUser';
    final defaultAvatar = user?.userMetadata?['avatar_url'] as String? ?? '';

    final profile = UserProfile(
      userId: user?.id ?? '30961573',
      nickname: defaultName,
      avatarUrl: defaultAvatar,
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
      coinBalance: 161480.0,
    );

    return ProfileState(
      profile: profile,
      recentWithdrawalText: 'yanboyy withdrew \$10.0',
    );
  }
}
