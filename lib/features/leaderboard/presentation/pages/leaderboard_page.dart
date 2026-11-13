import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../party/presentation/pages/region_selector_page.dart';
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

class _LeaderboardView extends StatefulWidget {
  const _LeaderboardView();

  @override
  State<_LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<_LeaderboardView> {
  String _selectedRegion = 'All';

  static const Map<String, String> _countryToFlag = {
    'All': '🌐',
    'Bangladesh': '🇧🇩',
    'Saudi Arabia': '🇸🇦',
    'United Arab Emirates': '🇦🇪',
    'Qatar': '🇶🇦',
    'Kuwait': '🇰🇼',
    'India': '🇮🇳',
    'Pakistan': '🇵🇰',
    'Philippines': '🇵🇭',
    'Indonesia': '🇮🇩',
    'Malaysia': '🇲🇾',
    'United States': '🇺🇸',
    'Nepal': '🇳🇵',
    'Jordan': '🇯🇴',
    'China': '🇨🇳',
    'Brazil': '🇧🇷',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BFA5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4D8), Color(0xFF00C9A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopHeader(context),
              _buildTimeframeToggle(context),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                      builder: (context, state) {
                        final flag = _countryToFlag[_selectedRegion];
                        final filteredEntries = (_selectedRegion == 'All' || flag == null)
                            ? state.entries
                            : state.entries.where((e) => e.flagEmoji == flag).toList();
                        final displayList = filteredEntries.isEmpty ? state.entries : filteredEntries;

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 90),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final entry = displayList[index];
                            return _buildRankRow(entry);
                          },
                        );
                      },
                    ),
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: isSelected ? 17 : 14,
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
              // Globe / Country Selector (Circled in user screenshot)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegionSelectorPage(
                        selectedRegion: _selectedRegion,
                        onSelectRegion: (region) {
                          setState(() {
                            _selectedRegion = region;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Region: $region'),
                              duration: const Duration(milliseconds: 900),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.gemEmerald,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedRegion != 'All' ? AppColors.goldCoin : Colors.white30,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _countryToFlag[_selectedRegion] ?? '🌐',
                        style: const TextStyle(fontSize: 15),
                      ),
                      if (_selectedRegion != 'All') ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
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
            color: Colors.white.withOpacity(0.15),
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
                        color: isDaily ? const Color(0xFF00BFA5) : Colors.white,
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
                        color: !isDaily ? const Color(0xFF00BFA5) : Colors.white,
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
          color: Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Center(child: rankBadge),
          ),
          const SizedBox(width: 8),
          CustomAvatar(
            imageUrl: entry.avatarUrl,
            radius: 20,
            hasVipFrame: entry.isVip,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
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
                      color: entry.isGems ? const Color(0xFF00B4D8) : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    entry.isGems ? Icons.diamond : Icons.monetization_on,
                    color: entry.isGems ? const Color(0xFF00B4D8) : const Color(0xFFF59E0B),
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '≈\$${entry.usdEquivalent.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 8,
                offset: Offset(0, -3),
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
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomAvatar(
                    imageUrl: myProfile.avatarUrl.isNotEmpty ? myProfile.avatarUrl : null,
                    radius: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          myProfile.nickname.isNotEmpty ? myProfile.nickname : 'Me',
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              balanceStr,
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.monetization_on, color: Color(0xFFF59E0B), size: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Anonymous',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 26,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Switch(
                        value: state.isAnonymous,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (_) {
                          context.read<LeaderboardBloc>().add(ToggleAnonymousEvent());
                        },
                      ),
                    ),
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
