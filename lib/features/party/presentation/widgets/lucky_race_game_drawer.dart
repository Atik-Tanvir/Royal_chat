import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class LuckyRaceGameDrawer extends StatefulWidget {
  final VoidCallback? onRechargeTap;

  const LuckyRaceGameDrawer({
    super.key,
    this.onRechargeTap,
  });

  static void show(BuildContext context, {VoidCallback? onRechargeTap}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LuckyRaceGameDrawer(onRechargeTap: onRechargeTap),
    );
  }

  @override
  State<LuckyRaceGameDrawer> createState() => _LuckyRaceGameDrawerState();
}

class _LuckyRaceGameDrawerState extends State<LuckyRaceGameDrawer> {
  int _selectedLane = 0; // 0: Stock, 1: ATV, 2: SUV
  int _selectedChip = 500;
  int _secondsRemaining = 33;
  bool _autoRepeat = false;
  Timer? _timer;

  final List<int> _chips = [100, 500, 1000, 5000, 10000];

  final List<Map<String, dynamic>> _lanes = [
    {
      'title': 'STOCK RACER',
      'sub': 'Balanced Speed',
      'odds': '2.2x',
      'pool': '340.5K',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.directions_car_filled,
      'myBet': 0,
    },
    {
      'title': 'ATV DESERT',
      'sub': 'High Torque',
      'odds': '3.4x',
      'pool': '210.8K',
      'color': const Color(0xFF10B981),
      'icon': Icons.two_wheeler,
      'myBet': 0,
    },
    {
      'title': 'SUV BEAST',
      'sub': 'Super Jackpot',
      'odds': '9.9x',
      'pool': '82.0K',
      'color': const Color(0xFFFF5252),
      'icon': Icons.agriculture,
      'myBet': 0,
    },
  ];

  final List<String> _recentWinners = ['Stock', 'SUV', 'Stock', 'ATV', 'Stock'];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _secondsRemaining = 45; // New round
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _placeBet() async {
    final currentUserId = AuthSessionManager.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to place bets!')),
      );
      return;
    }

    final profile = context.read<ProfileBloc>().state.profile;
    if (profile.coinBalance < _selectedChip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins! Please recharge.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _lanes[_selectedLane]['myBet'] =
          (_lanes[_selectedLane]['myBet'] as int) + _selectedChip;
    });

    try {
      final newBalance = profile.coinBalance - _selectedChip;
      await SupabaseConfig.client
          .from('profiles')
          .update({'coin_balance': newBalance})
          .eq('id', currentUserId);

      if (mounted) {
        context.read<ProfileBloc>().add(LoadUserProfileEvent());
      }
    } catch (e) {
      debugPrint('[LuckyRace] Bet balance update error: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bet $_selectedChip coins placed on ${_lanes[_selectedLane]['title']}!',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF6366F1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFFF0055)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_score, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'LUCKY RACE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group, size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '1,280',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE2C55).withValues(alpha: 0.2),
                    border: Border.all(
                      color: const Color(0xFFFE2C55).withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_secondsRemaining}s',
                        style: const TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total Pool Banner & History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Text(
                  'Pool: ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const Text(
                  '🪙 833.2K',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Past: ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
                ..._recentWinners.map((winner) {
                  Color c = winner == 'Stock'
                      ? const Color(0xFF3B82F6)
                      : (winner == 'ATV'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFF5252));
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      winner[0],
                      style: TextStyle(
                        color: c,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Betting Lanes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: List.generate(3, (index) {
                final lane = _lanes[index];
                final isSelected = _selectedLane == index;
                final Color laneColor = lane['color'] as Color;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLane = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 5,
                        right: index == 2 ? 0 : 5,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? laneColor.withValues(alpha: 0.15)
                            : const Color(0xFF1E2433),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? laneColor
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: laneColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          // Odds Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: laneColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lane['odds'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Car Icon
                          Icon(
                            lane['icon'] as IconData,
                            color: laneColor,
                            size: 38,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lane['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lane['sub'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Pool on this car
                          Text(
                            '🪙 ${lane['pool']}',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if ((lane['myBet'] as int) > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'My: ${lane['myBet']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Chips Selection Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _chips.map((chip) {
                        final isChipSelected = _selectedChip == chip;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedChip = chip),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isChipSelected
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF1E2433),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isChipSelected
                                    ? const Color(0xFFFFD700)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  size: 13,
                                  color: isChipSelected
                                      ? Colors.black87
                                      : const Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  chip >= 1000 ? '${chip ~/ 1000}K' : '$chip',
                                  style: TextStyle(
                                    color: isChipSelected
                                        ? Colors.black87
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Auto-repeat toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Auto',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: _autoRepeat,
                        onChanged: (val) => setState(() => _autoRepeat = val),
                        activeColor: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Bar: Balance & Bet Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                // Coins Balance Pill
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    final balance = profileState.profile.coinBalance.toInt();
                    final balanceStr = balance.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]},',
                    );

                    return GestureDetector(
                      onTap: widget.onRechargeTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2433),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              balanceStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.add_circle,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Big Bet Button
                Expanded(
                  child: GestureDetector(
                    onTap: _placeBet,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'BET ${_lanes[_selectedLane]['odds']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
