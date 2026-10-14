import 'package:flutter/material.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';

class SystemMessagesPage extends StatefulWidget {
  const SystemMessagesPage({super.key});

  @override
  State<SystemMessagesPage> createState() => _SystemMessagesPageState();
}

class _SystemMessagesPageState extends State<SystemMessagesPage> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSystemMessages();
  }

  Future<void> _fetchSystemMessages() async {
    try {
      final response = await SupabaseConfig.client
          .from('system_messages')
          .select()
          .order('created_at', ascending: true);
      if (response.isNotEmpty) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('SystemMessages fetch error: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gemEmerald, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'System Messages',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gemEmerald))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Render dynamic messages from Supabase or fallback
                if (_messages.isNotEmpty)
                  ..._messages.map((msg) => _buildDynamicMessageCard(msg))
                else ...[
                  // Fallback to demo cards matching Screenshot 12
                  _buildDefaultRewardCard(),
                  const SizedBox(height: 24),
                  _buildDefaultRankingCard(),
                ],
              ],
            ),
    );
  }

  Widget _buildDynamicMessageCard(Map<String, dynamic> msg) {
    final type = msg['type'] ?? 'notice';
    if (type == 'ranking') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildDefaultRankingCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Recent',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBellAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg['content']?.toString() ?? '',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultRewardCard() {
    return Column(
      children: [
        const Center(
          child: Text(
            '9/7 13:23',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBellAvatar(),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Dear user: 2,000 coins of Sign-in reward on 07/9/2026 has been sent to your account.',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultRankingCard() {
    return Column(
      children: [
        const Center(
          child: Text(
            '9/6 22:16',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBellAvatar(),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎉 Congratulations!',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // BlockMe Ranking Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9D58), Color(0xFF0072FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BlockMe Ranking',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Row(
                      children: [
                        Text('⭐ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'The top 10 in 09.06 round.',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ...[
                      'NO.1: Franco12345 won 12,163,358 coins',
                      'NO.2: Janiks10 won 11,905,534 coins',
                      'NO.3: Joda6149 won 10,150,975 coins',
                      'NO.4: nanad8354 won 9,742,560 coins',
                      'NO.5: »Md.Zihad💙 won 9,641,198 coins',
                      'NO.6: 『STAR』 won 8,099,143 coins',
                      'NO.7: ☆Anonymous☆ won 7,615,716 coins',
                      'NO.8: GaGon⭐ won 7,459,427 coins',
                      'NO.9: 榊LoneLly won 6,867,387 coins',
                      'NO.10: Clarkie❤️ won 6,271,189 coins',
                    ].map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          line,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      '🎁 Don\'t hesitate to join in it today!',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LeaderboardPage(initialTabIndex: 1),
                            ),
                          );
                        },
                        child: const Text(
                          'View >',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBellAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFD1FAE5),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.notifications,
          color: Color(0xFF10B981),
          size: 20,
        ),
      ),
    );
  }
}
