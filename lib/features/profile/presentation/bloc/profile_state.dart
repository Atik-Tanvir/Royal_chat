import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

class ProfileState extends Equatable {
  final UserProfile profile;
  final String recentWithdrawalText;
  final bool isLoading;

  const ProfileState({
    required this.profile,
    this.recentWithdrawalText = 'yanboyy withdrew \$10.0',
    this.isLoading = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    String? recentWithdrawalText,
    bool? isLoading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      recentWithdrawalText: recentWithdrawalText ?? this.recentWithdrawalText,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [profile, recentWithdrawalText, isLoading];
}
