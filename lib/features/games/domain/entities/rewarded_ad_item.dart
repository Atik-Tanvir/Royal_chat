import 'package:equatable/equatable.dart';

/// Domain entity representing an Admin-controlled Rewarded Ad.
class RewardedAdItem extends Equatable {
  final String id;
  final String title;
  final String network;
  final String description;
  final String imageUrl;
  final String targetUrl;
  final int rewardCoins;
  final int durationSeconds;
  final bool isEnabled;

  const RewardedAdItem({
    required this.id,
    required this.title,
    required this.network,
    required this.description,
    required this.imageUrl,
    required this.targetUrl,
    required this.rewardCoins,
    required this.durationSeconds,
    required this.isEnabled,
  });

  factory RewardedAdItem.fromJson(Map<String, dynamic> json) {
    return RewardedAdItem(
      id: json['id']?.toString() ?? 'ad_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Sponsored Ad',
      network: json['network']?.toString() ?? 'AdMob',
      description: json['description']?.toString() ?? 'Watch to earn free game coins.',
      imageUrl: json['imageUrl']?.toString() ?? '',
      targetUrl: json['targetUrl']?.toString() ?? '',
      rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 500,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 5,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        network,
        description,
        imageUrl,
        targetUrl,
        rewardCoins,
        durationSeconds,
        isEnabled,
      ];
}

class RewardedAdsConfig extends Equatable {
  final bool adsEnabled;
  final List<RewardedAdItem> activeAds;

  const RewardedAdsConfig({
    this.adsEnabled = true,
    this.activeAds = const [],
  });

  @override
  List<Object?> get props => [adsEnabled, activeAds];
}
