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
import '../widgets/create_room_dialog.dart';
import '../widgets/room_restriction_dialog.dart';
import 'live_audio_room_page.dart';
import 'region_selector_page.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../../../profile/presentation/pages/coins_wallet_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../chat/presentation/pages/system_messages_page.dart';

class PartyTabPage extends StatelessWidget {
  const PartyTabPage({super.key});

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
                      IconButton(
                        icon: const Icon(Icons.mail_outline_rounded, color: AppColors.goldCoin, size: 22),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SystemMessagesPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_events_rounded, color: AppColors.goldCoin, size: 22),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegionSelectorPage(),
                            ),
                          );
                        },
                        child: _buildFilterChip('All', icon: Icons.translate),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegionSelectorPage(),
                            ),
                          );
                        },
                        child: _buildFilterChip('All', icon: Icons.language),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Horizontal Icon Row
              SliverToBoxAdapter(
                child: BlocBuilder<PartyBloc, PartyState>(
                  builder: (context, state) {
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

                  // If a specific category filter is picked, show flat grid
                  if (state.selectedCategory != 'All') {
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
                            final room = state.filteredRooms[index];
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
                          childCount: state.filteredRooms.length,
                        ),
                      ),
                    );
                  }

                  // Otherwise show grouped sections matching screenshot 4
                  final luckyNumberRooms = state.allRooms.where((r) => r.category == 'Lucky Number').toList();
                  final luckyRaceRooms = state.allRooms.where((r) => r.category == 'Lucky Race').toList();
                  final chatRooms = state.allRooms.where((r) => r.category == 'Chatroom').toList();

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _buildRoomSection(context, 'Lucky Number', luckyNumberRooms, Icons.casino),
                      _buildRoomSection(context, 'Lucky Race', luckyRaceRooms, Icons.sports_motorsports),
                      _buildRoomSection(context, 'Chatroom', chatRooms, Icons.forum_rounded),
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
                onTap: () {
                  RoomRestrictionDialog.show(
                    context,
                    onJoinHotRoom: () {
                      final rooms = context.read<PartyBloc>().state.allRooms;
                      if (rooms.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveAudioRoomPage(room: rooms.first),
                          ),
                        );
                      }
                    },
                    onBypassCreate: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => CreateRoomDialog(
                          onCreate: (title, category) {
                            context.read<PartyBloc>().add(
                                  CreateNewRoomEvent(title: title, category: category),
                                );
                          },
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFDF00), Color(0xFFF59E0B)],
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
                      const Icon(Icons.mic_none_rounded, color: Colors.black87, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Host Royal Party',
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
        color: AppColors.primaryGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
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

  Widget _buildRoomSection(
    BuildContext context,
    String title,
    List<dynamic> rooms,
    IconData icon,
  ) {
    if (rooms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with title and "More >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.goldCoin, size: 18),
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
              Row(
                children: [
                  Text(
                    'More',
                    style: AppTextStyles.caption.copyWith(color: Colors.white60),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.white60),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 3-Column Grid for rooms in this section
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length > 3 ? 3 : rooms.length,
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
}
