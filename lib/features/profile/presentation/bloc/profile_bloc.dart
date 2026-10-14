import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(_createInitialState()) {
    on<LoadUserProfileEvent>((event, emit) {
      emit(_createInitialState());
    });

    on<RechargeCoinsEvent>((event, emit) {
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
        coinBalance: state.profile.coinBalance + event.amount,
      );
      emit(state.copyWith(profile: updatedProfile));
    });

    on<WithdrawGemsEvent>((event, emit) {
      if (state.profile.gemBalance >= event.gems) {
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
          gemBalance: state.profile.gemBalance - event.gems,
          coinBalance: state.profile.coinBalance,
        );
        emit(state.copyWith(profile: updatedProfile));
      }
    });
  }

  static ProfileState _createInitialState() {
    const profile = UserProfile(
      userId: 'User30961573',
      nickname: 'User30961573',
      avatarUrl: '',
      country: 'Bangladesh',
      gender: '♂ 19',
      age: 19,
      level: 0,
      isVip: true,
      friendsCount: 0,
      followingCount: 0,
      fansCount: 0,
      visitorsCount: 0,
      gemBalance: 0.0,
      coinBalance: 158980.0, // 158.98K
    );

    return const ProfileState(
      profile: profile,
      recentWithdrawalText: 'yanboyy withdrew \$10.0',
    );
  }
}
