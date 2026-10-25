import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/wallet_transaction.dart';

class ProfileState extends Equatable {
  final UserProfile profile;
  final String recentWithdrawalText;
  final List<WalletTransaction> transactions;
  final bool isLoading;

  const ProfileState({
    required this.profile,
    this.recentWithdrawalText = 'yanboyy withdrew \$10.0',
    this.transactions = const [],
    this.isLoading = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    String? recentWithdrawalText,
    List<WalletTransaction>? transactions,
    bool? isLoading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      recentWithdrawalText: recentWithdrawalText ?? this.recentWithdrawalText,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [profile, recentWithdrawalText, transactions, isLoading];
}
