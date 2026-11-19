import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/party_bloc.dart';
import '../bloc/party_event.dart';
import '../bloc/party_state.dart';
import '../widgets/party_room_card.dart';
import 'live_audio_room_page.dart';

class PartyCategoryRoomsPage extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const PartyCategoryRoomsPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    this.categoryColor = AppColors.goldCoin,
  });

  @override
  State<PartyCategoryRoomsPage> createState() => _PartyCategoryRoomsPageState();
}

class _PartyCategoryRoomsPageState extends State<PartyCategoryRoomsPage> {
  String _selectedCountry = 'All';

  final List<Map<String, String>> _countryOptions = const [
    {'name': 'All', 'flag': '🌐'},
    {'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'name': 'Pakistan', 'flag': '🇵🇰'},
    {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'Philippines', 'flag': '🇵🇭'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.bgMidGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: widget.categoryColor.withOpacity(0.5), width: 1.5),
              ),
              child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.categoryName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Explore all ${widget.categoryName} rooms',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocBuilder<PartyBloc, PartyState>(
        builder: (context, state) {
          // Filter by category
          final categoryRooms = state.allRooms
              .where((r) => r.category.toLowerCase() == widget.categoryName.toLowerCase())
              .toList();

          // Filter by selected country
          final displayRooms = _selectedCountry == 'All'
              ? categoryRooms
              : categoryRooms.where((r) {
                  final flag = _countryOptions.firstWhere(
                    (c) => c['name'] == _selectedCountry,
                    orElse: () => {'flag': ''},
                  )['flag'] ?? '';
                  return r.countryFlag.contains(flag) ||
                      r.title.toLowerCase().contains(_selectedCountry.toLowerCase()) ||
                      r.hostName.toLowerCase().contains(_selectedCountry.toLowerCase());
                }).toList();

          return RefreshIndicator(
            color: AppColors.gemEmerald,
            backgroundColor: AppColors.bgMidGreen,
            onRefresh: () async {
              context.read<PartyBloc>().add(const FetchPartyRoomsEvent());
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Top filter bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _countryOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final opt = _countryOptions[index];
                          final isSelected = _selectedCountry == opt['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCountry = opt['name']!;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.gemEmerald.withOpacity(0.2)
                                    : AppColors.bgMidGreen,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.gemEmerald
                                      : Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    opt['flag']!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    opt['name']!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Room count banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${displayRooms.length} Live Room${displayRooms.length == 1 ? '' : 's'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E676),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Now',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF00E676),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Rooms Grid or Empty State
                if (displayRooms.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.categoryIcon,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No live rooms in $_selectedCountry',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting "All" or another country',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gemEmerald,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedCountry = 'All';
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Show All Rooms'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
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
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
