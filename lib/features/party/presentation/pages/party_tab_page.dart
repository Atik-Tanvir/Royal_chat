import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/currency_badge.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../bloc/party_bloc.dart';
import '../bloc/party_event.dart';
import '../bloc/party_state.dart';
import '../widgets/party_category_bar.dart';
import '../widgets/party_room_card.dart';
import '../widgets/single_chat_card.dart';
import '../../domain/entities/party_room.dart';
import '../widgets/create_room_dialog.dart';
import '../widgets/room_restriction_dialog.dart';
import 'live_audio_room_page.dart';
import 'party_category_rooms_page.dart';
import 'region_selector_page.dart';
import '../../../profile/presentation/widgets/signin_reward_dialog.dart';
import '../../../profile/presentation/pages/task_center_page.dart';
import '../../../profile/presentation/pages/backpack_store_page.dart';
import '../../../games/presentation/pages/bucket_prediction_game_page.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class PartyTabPage extends StatefulWidget {
  const PartyTabPage({super.key});

  @override
  State<PartyTabPage> createState() => _PartyTabPageState();
}

class _PartyTabPageState extends State<PartyTabPage> {
  String _selectedLanguage = 'All';
  String _selectedRegion = 'All';

  void _openLanguagePickerSheet(BuildContext context) {
    final languages = [
      {'name': 'All', 'label': 'All Languages', 'flag': '🌐'},
      {'name': 'English', 'label': 'English', 'flag': '🇺🇸'},
      {'name': 'বাংলা', 'label': 'বাংলা (Bangla)', 'flag': '🇧🇩'},
      {'name': 'العربية', 'label': 'العربية (Arabic)', 'flag': '🇸🇦'},
      {'name': 'हिन्दी', 'label': 'हिन्दी (Hindi)', 'flag': '🇮🇳'},
      {'name': 'اردو', 'label': 'اردو (Urdu)', 'flag': '🇵🇰'},
      {'name': 'Bahasa', 'label': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF13231B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.translate, color: AppColors.gemCyan, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Select Room Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...languages.map((l) {
                final isSel = _selectedLanguage == l['name'];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(l['flag']!, style: const TextStyle(fontSize: 20)),
                  title: Text(
                    l['label']!,
                    style: TextStyle(
                      color: isSel ? AppColors.gemCyan : Colors.white,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  trailing: isSel
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.gemCyan)
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = l['name']!);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRegionPicker(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => RegionSelectorPage(
          selectedRegion: _selectedRegion,
          onSelectRegion: (reg) {
            if (mounted) setState(() => _selectedRegion = reg);
          },
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedRegion = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Top Bar with Royal Brand Logo & Currencies
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      // Royal Brand Logo & Title
                      const RoyalBrandLogo(size: 34, showText: true),
                      const Spacer(),
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          final coins = profileState.profile.coinBalance;
                          final amountStr = coins >= 1000
                              ? '${(coins / 1000).toStringAsFixed(2)}K'
                              : coins.toInt().toString();
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CoinsWalletPage(),
                                ),
                              );
                            },
                            child: CurrencyBadge(amount: amountStr),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      const SizedBox(width: 6),
                      // Daily Sign-in Reward Calendar Icon (Next to award)
                      GestureDetector(
                        onTap: () {
                          SignInRewardDialog.show(context);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFFFE082),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 8-Item Bucket Game Quick Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BucketPredictionGamePage()),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFFFD180),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3D00).withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.stars_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Task Center Quick Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TaskCenterPage()),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFB9F6CA),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.assignment_turned_in_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Mall & Backpack Quick Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BackpackStorePage()),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E24AA), Color(0xFFE91E63)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFF48FB1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Award / Leaderboard Trophy Icon
                      IconButton(
                        icon: const Icon(Icons.emoji_events_rounded, color: AppColors.goldCoin, size: 26),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LeaderboardPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Royal Hero Promotional Banner ("Royal Championship VIP")
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaderboardPage(initialTabIndex: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0C4638),
                            Color(0xFF136852),
                            Color(0xFF2A5240),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.borderGold.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: AppColors.goldCoin.withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldCoin,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'SEASON 1',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Royal Voice Arena',
                                      style: AppTextStyles.headerMedium.copyWith(
                                        color: const Color(0xFFFFF8DC),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.emoji_events, color: AppColors.goldCoin, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Grand Pool \$10,000',
                                      style: AppTextStyles.titleBold.copyWith(
                                        color: AppColors.goldCoin,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.diamond, color: AppColors.gemCyan, size: 14),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFF1E3A2F), Color(0xFF0B2920)],
                              ),
                              border: Border.all(color: AppColors.borderGold, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldCoin.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: RoyalBrandLogo(size: 34),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sub-tabs: Follow, Party, Chat, Top
              SliverToBoxAdapter(
                child: BlocBuilder<PartyBloc, PartyState>(
                  builder: (context, state) {
                    final tabs = ['Follow', 'Party', 'Chat', 'Top'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: tabs.map((tab) {
                          final isSelected = state.selectedSubTab == tab;
                          return GestureDetector(
                            onTap: () => context.read<PartyBloc>().add(SelectSubTabEvent(tab)),
                            child: Column(
                              children: [
                                Text(
                                  tab,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isSelected ? Colors.white : Colors.white60,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isSelected)
                                  Container(
                                    width: 20,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppColors.gemEmerald,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              // Filter Dropdown Chips (Language / Country)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openLanguagePickerSheet(context),
                        child: _buildFilterChip(
                          _selectedLanguage,
                          icon: Icons.translate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _openRegionPicker(context),
                        child: _buildFilterChip(
                          _selectedRegion,
                          icon: Icons.language,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Horizontal Icon Row (Only shown when Party sub-tab is active)
              SliverToBoxAdapter(
                child: BlocBuilder<PartyBloc, PartyState>(
                  builder: (context, state) {
                    if (state.selectedSubTab != 'Party') {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: PartyCategoryBar(
                        selectedCategory: state.selectedCategory,
                        onSelectCategory: (cat) {
                          context.read<PartyBloc>().add(SelectCategoryFilterEvent(cat));
                        },
                      ),
                    );
                  },
                ),
              ),

              // Categorized Room Cards
              BlocBuilder<PartyBloc, PartyState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.gemEmerald),
                      ),
                    );
                  }

                  // Single Host 2-column view when "Chat" tab is selected (Matches Gamegala Single Host layout)
                  if (state.selectedSubTab == 'Chat') {
                    return _buildSingleChatGrid(context);
                  }

                  // If a specific category filter is picked, show flat grid
                  if (state.selectedCategory != 'All') {
                    final displayRooms = _selectedRegion == 'All'
                        ? state.filteredRooms
                        : state.filteredRooms.where((r) {
                            return r.countryFlag.contains(_selectedRegion) ||
                                r.title.toLowerCase().contains(_selectedRegion.toLowerCase());
                          }).toList();

                    if (displayRooms.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getCategoryIcon(state.selectedCategory),
                                  size: 60,
                                  color: Colors.white24,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No live rooms in ${state.selectedCategory}',
                                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Explore all categories or change region filter',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white38),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gemEmerald,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () {
                                    context.read<PartyBloc>().add(const SelectCategoryFilterEvent('All'));
                                  },
                                  child: const Text('Show All Rooms'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final room = displayRooms[index];
                            return PartyRoomCard(
                              room: room,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LiveAudioRoomPage(room: room),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: displayRooms.length,
                        ),
                      ),
                    );
                  }

                  // Otherwise show grouped sections matching screenshot 4
                  final baseRooms = _selectedRegion == 'All'
                      ? state.allRooms
                      : state.allRooms.where((r) {
                          return r.countryFlag.contains(_selectedRegion) ||
                              r.title.toLowerCase().contains(_selectedRegion.toLowerCase());
                        }).toList();

                  final luckyNumberRooms = baseRooms.where((r) => r.category == 'Lucky Number').toList();
                  final luckyRaceRooms = baseRooms.where((r) => r.category == 'Lucky Race').toList();
                  final chatRooms = baseRooms.where((r) => r.category == 'Chatroom').toList();
                  final pkRooms = baseRooms.where((r) => r.category == 'PK').toList();

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _buildRoomSection(context, 'Lucky Number', luckyNumberRooms, Icons.casino_rounded, const Color(0xFF8B5CF6)),
                      _buildRoomSection(context, 'Lucky Race', luckyRaceRooms, Icons.sports_motorsports_rounded, const Color(0xFFFFB800)),
                      _buildRoomSection(context, 'Chatroom', chatRooms, Icons.forum_rounded, const Color(0xFFFF6B6B)),
                      _buildRoomSection(context, 'PK', pkRooms, Icons.offline_bolt_rounded, const Color(0xFFFF3366)),
                      const SizedBox(height: 90), // Space for floating Create Room button
                    ]),
                  );
                },
              ),
            ],
          ),

          // Floating "🎮 Create a Room" Button matching Screenshot 4
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: GestureDetector(
                onTap: () => _openCreateRoomModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldCoin.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_esports_rounded, color: Colors.black87, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Create a Room',
                        style: AppTextStyles.titleBold.copyWith(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gemCyan),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white70),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Lucky Number':
        return Icons.casino_rounded;
      case 'Lucky Race':
        return Icons.sports_motorsports_rounded;
      case 'Chatroom':
        return Icons.forum_rounded;
      case 'PK':
        return Icons.offline_bolt_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Widget _buildRoomSection(
    BuildContext context,
    String title,
    List<dynamic> rooms,
    IconData icon, [
    Color? iconColor,
  ]) {
    if (rooms.isEmpty) return const SizedBox.shrink();

    final accentColor = iconColor ?? AppColors.goldCoin;

    void openMorePage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PartyCategoryRoomsPage(
            categoryName: title,
            categoryIcon: icon,
            categoryColor: accentColor,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with title and "More >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: openMorePage,
                child: Row(
                  children: [
                    Icon(icon, color: accentColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: AppTextStyles.titleBold.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: openMorePage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        'More',
                        style: AppTextStyles.caption.copyWith(color: Colors.white60),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.white60),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 3-Column Grid for rooms in this section (shows up to 6 rooms)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length > 6 ? 6 : rooms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return PartyRoomCard(
                room: room,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveAudioRoomPage(room: room),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSingleChatGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final host = dummySingleChatHosts[index % dummySingleChatHosts.length];
            return SingleChatCard(
              host: host,
              onTap: () => _openHostSession(context, host),
              onCallTap: () => _openHostSession(context, host),
            );
          },
          childCount: dummySingleChatHosts.length,
        ),
      ),
    );
  }

  void _openHostSession(BuildContext context, SingleChatHost host) {
    final hostRoom = PartyRoom(
      id: host.id,
      title: '${host.name}\'s Live Chat',
      hostName: host.name,
      hostAvatar: host.avatarUrl,
      countryFlag: host.countryFlag,
      onlineCount: 1,
      category: 'Chatroom',
      seatedAvatars: [host.avatarUrl],
      isLive: host.isOnline,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveAudioRoomPage(room: hostRoom),
      ),
    );
  }

  void _openCreateRoomModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CreateRoomDialog(
        onCreate: (title, category) {
          final profile = context.read<ProfileBloc>().state.profile;
          final myName = profile.nickname.isNotEmpty ? profile.nickname : 'Host';
          final myAvatar = profile.avatarUrl.isNotEmpty
              ? profile.avatarUrl
              : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
          final myFlag = profile.countryFlag.isNotEmpty ? profile.countryFlag : '🇧🇩';

          final newRoom = PartyRoom(
            id: 'room_${DateTime.now().millisecondsSinceEpoch}',
            title: title.trim().isNotEmpty ? title.trim() : '$myName\'s Party Arena',
            hostName: myName,
            hostAvatar: myAvatar,
            countryFlag: myFlag,
            onlineCount: 1,
            category: category,
            seatedAvatars: [myAvatar],
            isLive: true,
          );

          context.read<PartyBloc>().add(
                CreateNewRoomEvent(title: newRoom.title, category: newRoom.category),
              );

          // Direct Navigation into the created room!
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveAudioRoomPage(room: newRoom),
            ),
          );
        },
      ),
    );
  }
}
