import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String username;
  final String countryFlag;
  final String countryName;

  const UserDetailPage({
    super.key,
    this.userId = '30961573',
    this.username = 'User30961573',
    this.countryFlag = '🇧🇩',
    this.countryName = 'Bangladesh',
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7F0E6),
      body: Stack(
        children: [
          // Top Cat Mascot Illustration Cover
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFBCE7D6), Color(0xFFDFF6ED)],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cat Illustration
                  Positioned(
                    bottom: 20,
                    child: Column(
                      children: [
                        // Hat + Face
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: 220,
                              height: 180,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Center(
                                child: Text('🐱', style: TextStyle(fontSize: 120)),
                              ),
                            ),
                            // Fedora hat overlay
                            Positioned(
                              top: -10,
                              right: 25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF262626),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text('🎩', style: TextStyle(fontSize: 32)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Top User ID & Online Pill
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID:${widget.userId}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                              SizedBox(width: 5),
                              Text(
                                'Online',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Nav Buttons (Back & Edit)
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  widget.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile features active.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom White Sheet Card with Info / Moments Tabs
          Positioned.fill(
            top: 320,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -6)),
                ],
              ),
              child: Column(
                children: [
                  // Subtabs Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: AppColors.gemEmerald,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: const Color(0xFF0D5E46),
                      labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      unselectedLabelColor: const Color(0xFF94A3B8),
                      unselectedLabelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                      tabs: const [
                        Tab(text: 'Info'),
                        Tab(text: 'Moments'),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInfoTab(),
                        _buildMomentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Avatar + Name + Gender/Age Row
        Row(
          children: [
            const CustomAvatar(radius: 28),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0072FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '♂ 19',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Personal signature
        const Text(
          'No personal signature',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Country & Language Chips
        Row(
          children: [
            _buildBadgeChip('🇧🇩 Bangladesh'),
            const SizedBox(width: 8),
            _buildBadgeChip('🌐 English'),
          ],
        ),
        const SizedBox(height: 24),

        // Wealth Level & Charm Level Cards
        Row(
          children: [
            // Wealth Level Card (Cyan)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF80DEEA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFF00ACC1), size: 30),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wealth Level',
                          style: TextStyle(
                            color: Color(0xFF00838F),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0097A7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '💎 LV0',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Charm Level Card (Pink/Purple)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF48FB1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: Color(0xFFD81B60), size: 30),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Charm Level',
                          style: TextStyle(
                            color: Color(0xFFAD1457),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2185B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '💎 LV0',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

  Widget _buildMomentsTab() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F7F2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🐱', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 12),
              const Text(
                'No Data',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // FAB Airplane button
        Positioned(
          bottom: 24,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: AppColors.gemEmerald,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Send instant greeting to user.')),
              );
            },
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
