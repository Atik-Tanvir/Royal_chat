import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/currency_badge.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'coins_wallet_page.dart';

class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int points;
  final int rewardCoins;
  final int currentProgress;
  final int targetProgress;
  final bool isClaimed;

  TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.points,
    required this.rewardCoins,
    required this.currentProgress,
    required this.targetProgress,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= targetProgress;

  TaskItem copyWith({bool? isClaimed, int? currentProgress}) {
    return TaskItem(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      points: points,
      rewardCoins: rewardCoins,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class TaskCenterPage extends StatefulWidget {
  const TaskCenterPage({super.key});

  @override
  State<TaskCenterPage> createState() => _TaskCenterPageState();
}

class _TaskCenterPageState extends State<TaskCenterPage> {
  int _dailyPoints = 60;
  final List<TaskItem> _tasks = [
    TaskItem(
      id: 'task_signin',
      title: 'Daily Check-in',
      subtitle: 'Open the app and complete sign-in',
      icon: '📅',
      points: 20,
      rewardCoins: 2000,
      currentProgress: 1,
      targetProgress: 1,
      isClaimed: true,
    ),
    TaskItem(
      id: 'task_room_time',
      title: 'Voice Room Explorer',
      subtitle: 'Spend 10 minutes in any voice room',
      icon: '🎙️',
      points: 20,
      rewardCoins: 1500,
      currentProgress: 10,
      targetProgress: 10,
      isClaimed: false,
    ),
    TaskItem(
      id: 'task_play_games',
      title: 'Casual Gamer',
      subtitle: 'Play 3 rounds of Bucket Spin or Lucky Race',
      icon: '🎮',
      points: 20,
      rewardCoins: 1200,
      currentProgress: 3,
      targetProgress: 3,
      isClaimed: false,
    ),
    TaskItem(
      id: 'task_send_gift',
      title: 'Heartwarming Gift',
      subtitle: 'Send 1 virtual gift to any host',
      icon: '🎁',
      points: 20,
      rewardCoins: 1000,
      currentProgress: 1,
      targetProgress: 1,
      isClaimed: false,
    ),
    TaskItem(
      id: 'task_watch_ad',
      title: 'Support Platform',
      subtitle: 'Watch a rewarded video promo',
      icon: '📺',
      points: 10,
      rewardCoins: 800,
      currentProgress: 1,
      targetProgress: 1,
      isClaimed: false,
    ),
    TaskItem(
      id: 'task_send_messages',
      title: 'Social Butterfly',
      subtitle: 'Send 5 chat messages to friends',
      icon: '💬',
      points: 10,
      rewardCoins: 500,
      currentProgress: 5,
      targetProgress: 5,
      isClaimed: false,
    ),
  ];

  final Set<int> _openedChests = {};

  @override
  void initState() {
    super.initState();
    _loadClaimedTasks();
  }

  Future<void> _loadClaimedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      for (int i = 0; i < _tasks.length; i++) {
        final key = 'task_${_tasks[i].id}_$today';
        if (prefs.getBool(key) == true) {
          _tasks[i] = _tasks[i].copyWith(isClaimed: true);
        }
      }
      _dailyPoints = _calculateTotalPoints();
    });
  }

  int _calculateTotalPoints() {
    int total = 0;
    for (final t in _tasks) {
      if (t.isClaimed) total += t.points;
    }
    return total;
  }

  void _claimTask(TaskItem task) async {
    if (task.isClaimed || !task.isCompleted) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('task_${task.id}_$today', true);

    if (!mounted) return;

    // Credit coins to user profile bloc
    context.read<ProfileBloc>().add(
          ClaimDailyRewardEvent(
            dayNumber: 1,
            rewardCoins: task.rewardCoins.toDouble(),
          ),
        );

    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isClaimed: true);
      }
      _dailyPoints = _calculateTotalPoints();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Claimed ${task.rewardCoins} Coins & +${task.points} Activity Points!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChest(int requiredPoints, int rewardGems) {
    if (_dailyPoints < requiredPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reach $requiredPoints points to unlock this mystery chest!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_openedChests.contains(requiredPoints)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chest already opened today!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _openedChests.add(requiredPoints);
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C2E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎁', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            const Text(
              'Mystery Chest Opened!',
              style: TextStyle(
                color: AppColors.goldCoin,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You received $rewardGems Diamonds & Golden Lion Badge!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldCoin,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF051C15),
      body: GemgalaBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _buildMilestoneCard(),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Missions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Resets in 14h 22m',
                          style: TextStyle(
                            color: AppColors.goldCoin.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._tasks.map((task) => _buildTaskCard(task)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Task Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final coins = state.profile.coinBalance;
              final amountStr = coins >= 1000
                  ? '${(coins / 1000).toStringAsFixed(1)}K'
                  : coins.toInt().toString();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                  );
                },
                child: CurrencyBadge(amount: amountStr),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard() {
    final progressPct = (_dailyPoints / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C3A), Color(0xFF093327)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1B6B53)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Activity Points',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '$_dailyPoints',
                        style: const TextStyle(
                          color: AppColors.goldCoin,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        ' / 100',
                        style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.goldCoin.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.goldCoin, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Season 1',
                      style: TextStyle(
                        color: AppColors.goldCoin,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Milestone Progress Bar with Chests
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressPct,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Milestone Chests: 25, 50, 75, 100
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChestNode(25, 50, '🥉'),
              _buildChestNode(50, 100, '🥈'),
              _buildChestNode(75, 250, '🥇'),
              _buildChestNode(100, 500, '👑'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChestNode(int requiredPts, int gemsReward, String icon) {
    final isReached = _dailyPoints >= requiredPts;
    final isOpened = _openedChests.contains(requiredPts);

    return GestureDetector(
      onTap: () => _openChest(requiredPts, gemsReward),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isOpened
                  ? Colors.black38
                  : isReached
                      ? const Color(0xFFD97706)
                      : const Color(0xFF09291E),
              shape: BoxShape.circle,
              border: Border.all(
                color: isReached ? const Color(0xFFFDE68A) : Colors.white24,
                width: 1.5,
              ),
              boxShadow: isReached && !isOpened
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isOpened ? '✓' : icon,
                style: TextStyle(
                  fontSize: isOpened ? 18 : 20,
                  color: isOpened ? Colors.white70 : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$requiredPts pts',
            style: TextStyle(
              color: isReached ? AppColors.goldCoin : Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2B20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isClaimed
              ? Colors.transparent
              : task.isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF041812),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            alignment: Alignment.center,
            child: Text(task.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldCoin.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '+${task.rewardCoins}',
                            style: const TextStyle(
                              color: AppColors.goldCoin,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${task.points} pts',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action button (Claimed, Claim, or In Progress)
          if (task.isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Claimed',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (task.isCompleted)
            GestureDetector(
              onTap: () => _claimTask(task),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Claim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${task.currentProgress}/${task.targetProgress}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
