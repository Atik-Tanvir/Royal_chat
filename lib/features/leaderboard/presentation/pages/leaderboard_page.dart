import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class LeaderboardPage extends StatelessWidget {
  final int initialTabIndex;

  const LeaderboardPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = LeaderboardBloc();
        if (initialTabIndex > 0 &&
            initialTabIndex < LeaderboardType.values.length) {
          bloc.add(
            ChangeLeaderboardTypeEvent(LeaderboardType.values[initialTabIndex]),
          );
        }
        return bloc;
      },
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkEmerald,
      body: GemgalaBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopHeader(context),
              _buildTimeframeToggle(context),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                  builder: (context, state) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        return _buildRankRow(entry);
                      },
                    );
                  },
                ),
              ),
              _buildStickyUserFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        final tabs = [
          {'title': 'Wealth', 'type': LeaderboardType.wealth},
          {'title': 'Game', 'type': LeaderboardType.game},
          {'title': 'Charm', 'type': LeaderboardType.charm},
          {'title': 'Invitation', 'type': LeaderboardType.invitation},
        ];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: tabs.map((tab) {
                    final isSelected = state.currentType == tab['type'];
                    return GestureDetector(
                      onTap: () {
                        context
                            .read<LeaderboardBloc>()
                            .add(ChangeLeaderboardTypeEvent(tab['type'] as LeaderboardType));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tab['title'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: isSelected ? 18 : 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.gemCyan,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          else
                            const SizedBox(height: 3),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Icon(Icons.public_rounded, color: Colors.white70, size: 22),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeframeToggle(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        final isDaily = state.currentTimeframe == LeaderboardTimeframe.daily;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<LeaderboardBloc>()
                        .add(const ChangeLeaderboardTimeframeEvent(LeaderboardTimeframe.daily));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDaily ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Daily',
                      style: TextStyle(
                        color: isDaily ? AppColors.darkEmerald : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<LeaderboardBloc>()
                        .add(const ChangeLeaderboardTimeframeEvent(LeaderboardTimeframe.monthly));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: !isDaily ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Monthly',
                      style: TextStyle(
                        color: !isDaily ? AppColors.darkEmerald : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankRow(LeaderboardEntry entry) {
    Widget rankBadge;
    if (entry.rank == 1) {
      rankBadge = const Text('👑', style: TextStyle(fontSize: 22));
    } else if (entry.rank == 2) {
      rankBadge = const Text('🥈', style: TextStyle(fontSize: 20));
    } else if (entry.rank == 3) {
      rankBadge = const Text('🥉', style: TextStyle(fontSize: 20));
    } else {
      rankBadge = Text(
        '${entry.rank}',
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.rank <= 3
              ? (entry.rank == 1
                  ? AppColors.goldCoin.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15))
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Center(child: rankBadge),
          ),
          const SizedBox(width: 8),
          CustomAvatar(
            imageUrl: entry.avatarUrl,
            radius: 20,
            hasVipFrame: entry.isVip,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(entry.flagEmoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: entry.gender == '♂' ? const Color(0xFF0072FF) : const Color(0xFFFF2A6D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.gender} ${entry.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💎 LV${entry.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    entry.amountFormatted,
                    style: TextStyle(
                      color: entry.isGems ? AppColors.gemCyan : AppColors.goldCoin,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    entry.isGems ? Icons.diamond : Icons.monetization_on,
                    color: entry.isGems ? AppColors.gemCyan : AppColors.goldCoin,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '≈\$${entry.usdEquivalent.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyUserFooter(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF063327),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final myProfile = profileState.profile;
              final balanceStr = myProfile.coinBalance >= 1000
                  ? '${(myProfile.coinBalance / 1000).toStringAsFixed(1)}K'
                  : myProfile.coinBalance.toInt().toString();

              return Row(
                children: [
                  Text(
                    '${state.myRank}+',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomAvatar(
                    imageUrl: myProfile.avatarUrl.isNotEmpty ? myProfile.avatarUrl : null,
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        myProfile.nickname.isNotEmpty ? myProfile.nickname : 'Me',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            balanceStr,
                            style: const TextStyle(
                              color: AppColors.goldCoin,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 12),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Anonymous',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Switch(
                    value: state.isAnonymous,
                    activeColor: AppColors.gemEmerald,
                    onChanged: (_) {
                      context.read<LeaderboardBloc>().add(ToggleAnonymousEvent());
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
