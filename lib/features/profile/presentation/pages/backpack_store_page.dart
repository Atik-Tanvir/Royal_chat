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

enum StoreCategory { frame, ride, bubble }

class StoreItem {
  final String id;
  final String name;
  final StoreCategory category;
  final int coinPrice;
  final String iconEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;
  final String duration;

  const StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.coinPrice,
    required this.iconEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    this.duration = '30 Days',
  });
}

class BackpackStorePage extends StatefulWidget {
  final int initialTabIndex; // 0 for Mall, 1 for Backpack
  const BackpackStorePage({super.key, this.initialTabIndex = 0});

  @override
  State<BackpackStorePage> createState() => _BackpackStorePageState();
}

class _BackpackStorePageState extends State<BackpackStorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StoreCategory _selectedCategory = StoreCategory.frame;

  // Selected item for live interactive preview
  StoreItem? _previewItem;

  // Owned item IDs saved in SharedPreferences
  Set<String> _ownedItemIds = {};

  // Currently equipped items
  String? _equippedFrameId;
  String? _equippedRideId;
  String? _equippedBubbleId;

  static const List<StoreItem> catalog = [
    // --- AVATAR FRAMES ---
    StoreItem(
      id: 'frame_dragon',
      name: 'Imperial Dragon',
      category: StoreCategory.frame,
      coinPrice: 5000,
      iconEmoji: '🐉',
      primaryColor: Color(0xFFFFB300),
      secondaryColor: Color(0xFFFF3D00),
      description: 'Golden Imperial Dragon halo with animated embers',
    ),
    StoreItem(
      id: 'frame_cyber',
      name: 'Cyber Neon',
      category: StoreCategory.frame,
      coinPrice: 3500,
      iconEmoji: '⚡',
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFFD500F9),
      description: 'Futuristic glowing cyberpunk neon ring',
    ),
    StoreItem(
      id: 'frame_royalty',
      name: 'Diamond Royalty',
      category: StoreCategory.frame,
      coinPrice: 8000,
      iconEmoji: '👑',
      primaryColor: Color(0xFF00E676),
      secondaryColor: Color(0xFF2979FF),
      description: 'Crown of royal gemstones for prestigious hosts',
    ),
    StoreItem(
      id: 'frame_phoenix',
      name: 'Phoenix Flame',
      category: StoreCategory.frame,
      coinPrice: 12000,
      iconEmoji: '🔥',
      primaryColor: Color(0xFFFF5252),
      secondaryColor: Color(0xFFFFAB00),
      description: 'Blazing eternal fire frame of supreme glory',
    ),

    // --- ENTRANCE RIDES ---
    StoreItem(
      id: 'ride_supercar',
      name: 'Royal Supercar',
      category: StoreCategory.ride,
      coinPrice: 15000,
      iconEmoji: '🏎️',
      primaryColor: Color(0xFFFF1744),
      secondaryColor: Color(0xFFFFC107),
      description: 'Roaring sports car grand arrival banner in voice rooms',
    ),
    StoreItem(
      id: 'ride_dragon',
      name: 'Flying Dragon',
      category: StoreCategory.ride,
      coinPrice: 25000,
      iconEmoji: '🐲',
      primaryColor: Color(0xFFFF9100),
      secondaryColor: Color(0xFFFF1744),
      description: 'Mythical dragon descending with storm flashes on join',
    ),
    StoreItem(
      id: 'ride_rocket',
      name: 'Space Shuttle',
      category: StoreCategory.ride,
      coinPrice: 10000,
      iconEmoji: '🚀',
      primaryColor: Color(0xFF2979FF),
      secondaryColor: Color(0xFF00E5FF),
      description: 'Galactic rocket blastoff room entrance banner',
    ),
    StoreItem(
      id: 'ride_pegasus',
      name: 'Golden Pegasus',
      category: StoreCategory.ride,
      coinPrice: 30000,
      iconEmoji: '🦄',
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFF06292),
      description: 'Celestial winged steed lighting up the whole room',
    ),

    // --- CHAT BUBBLES ---
    StoreItem(
      id: 'bubble_luxury',
      name: 'Golden Luxury',
      category: StoreCategory.bubble,
      coinPrice: 2000,
      iconEmoji: '✨',
      primaryColor: Color(0xFFFFC107),
      secondaryColor: Color(0xFFFF8F00),
      description: 'Sparkling golden borders on all voice room messages',
    ),
    StoreItem(
      id: 'bubble_emerald',
      name: 'Emerald Glow',
      category: StoreCategory.bubble,
      coinPrice: 1500,
      iconEmoji: '💎',
      primaryColor: Color(0xFF00E676),
      secondaryColor: Color(0xFF1DE9B6),
      description: 'Luminous deep green neon crystal speech bubble',
    ),
    StoreItem(
      id: 'bubble_cyber',
      name: 'Cyber Matrix',
      category: StoreCategory.bubble,
      coinPrice: 2500,
      iconEmoji: '🌌',
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF7C4DFF),
      description: 'Matrix hologram text border for party conversations',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _previewItem = catalog.first;
    _loadState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ownedItemIds = prefs.getStringList('backpack_owned_items')?.toSet() ?? {
        'frame_dragon', // Default starter unlocked
      };
      _equippedFrameId = prefs.getString('equipped_avatar_frame') ?? 'frame_dragon';
      _equippedRideId = prefs.getString('equipped_entrance_ride');
      _equippedBubbleId = prefs.getString('equipped_chat_bubble');
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('backpack_owned_items', _ownedItemIds.toList());
    if (_equippedFrameId != null) {
      await prefs.setString('equipped_avatar_frame', _equippedFrameId!);
    } else {
      await prefs.remove('equipped_avatar_frame');
    }
    if (_equippedRideId != null) {
      await prefs.setString('equipped_entrance_ride', _equippedRideId!);
    } else {
      await prefs.remove('equipped_entrance_ride');
    }
    if (_equippedBubbleId != null) {
      await prefs.setString('equipped_chat_bubble', _equippedBubbleId!);
    } else {
      await prefs.remove('equipped_chat_bubble');
    }
  }

  bool _isItemEquipped(StoreItem item) {
    switch (item.category) {
      case StoreCategory.frame:
        return _equippedFrameId == item.id;
      case StoreCategory.ride:
        return _equippedRideId == item.id;
      case StoreCategory.bubble:
        return _equippedBubbleId == item.id;
    }
  }

  void _toggleEquip(StoreItem item) {
    setState(() {
      switch (item.category) {
        case StoreCategory.frame:
          _equippedFrameId = (_equippedFrameId == item.id) ? null : item.id;
          break;
        case StoreCategory.ride:
          _equippedRideId = (_equippedRideId == item.id) ? null : item.id;
          break;
        case StoreCategory.bubble:
          _equippedBubbleId = (_equippedBubbleId == item.id) ? null : item.id;
          break;
      }
    });
    _saveState();

    final isNowEquipped = _isItemEquipped(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowEquipped
              ? '${item.name} equipped successfully!'
              : '${item.name} unequipped.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isNowEquipped ? AppColors.gemEmerald : Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _buyItem(StoreItem item, ProfileState profileState) {
    final currentCoins = profileState.profile.coinBalance;
    if (currentCoins < item.coinPrice) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0D241C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E4535)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.goldCoin),
              SizedBox(width: 8),
              Text('Insufficient Coins', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Text(
            'You need ${item.coinPrice} Coins to purchase ${item.name}. Your balance is ${currentCoins.toInt()} Coins.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldCoin,
                foregroundColor: Colors.black,
              ),
              child: const Text('Recharge', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    // Confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D241C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E4535)),
        ),
        title: Row(
          children: [
            Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Text('Unlock ${item.name}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price (${'30 Days'})', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${item.coinPrice}',
                        style: const TextStyle(
                          color: AppColors.goldCoin,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Deduct coins via ProfileBloc
              final newBalance = (currentCoins - item.coinPrice).clamp(0, double.infinity).toDouble();
              context.read<ProfileBloc>().add(
                    ProfileBalancesUpdatedFromRealtimeEvent(
                      coinBalance: newBalance,
                    ),
                  );

              setState(() {
                _ownedItemIds.add(item.id);
                // Auto-equip on purchase
                switch (item.category) {
                  case StoreCategory.frame:
                    _equippedFrameId = item.id;
                    break;
                  case StoreCategory.ride:
                    _equippedRideId = item.id;
                    break;
                  case StoreCategory.bubble:
                    _equippedBubbleId = item.id;
                    break;
                }
              });
              _saveState();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unlocked and equipped ${item.name}! 🎉'),
                  backgroundColor: AppColors.gemEmerald,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gemEmerald,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Mall & Backpack',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                final coins = profileState.profile.coinBalance;
                final amountStr = coins >= 1000
                    ? '${(coins / 1000).toStringAsFixed(1)}K'
                    : coins.toInt().toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoinsWalletPage()),
                      );
                    },
                    child: CurrencyBadge(amount: amountStr),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gemEmerald,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Mall (Store) 🛍️'),
              Tab(text: 'Backpack (My Items) 🎒'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Live Interactive Preview Header
            _buildInteractivePreview(),

            // Category Filter Pills
            _buildCategorySelector(),

            // Tab View: Store Catalog vs My Backpack
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCatalogGrid(isMall: true),
                  _buildCatalogGrid(isMall: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePreview() {
    final preview = _previewItem ?? catalog.first;
    final isEquipped = _isItemEquipped(preview);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F2E23),
            preview.primaryColor.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: preview.primaryColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: preview.primaryColor.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Active Frame
          Stack(
            alignment: Alignment.center,
            children: [
              // Frame Halo Glow
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      preview.primaryColor,
                      preview.secondaryColor,
                      preview.primaryColor,
                    ],
                  ),
                ),
              ),
              // Inner border
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0A1B14),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                  ),
                ),
              ),
              // Category icon badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                    border: Border.all(color: preview.primaryColor, width: 1.5),
                  ),
                  child: Text(preview.iconEmoji, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Item Details & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        preview.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isEquipped)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gemEmerald,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'EQUIPPED',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  preview.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        preview.category == StoreCategory.frame
                            ? 'Avatar Frame'
                            : preview.category == StoreCategory.ride
                                ? 'Entrance Ride'
                                : 'Chat Bubble',
                        style: TextStyle(
                          color: preview.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${preview.duration}',
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildCategoryPill('Avatar Frames', StoreCategory.frame, '👑'),
          const SizedBox(width: 8),
          _buildCategoryPill('Entrance Rides', StoreCategory.ride, '🚀'),
          const SizedBox(width: 8),
          _buildCategoryPill('Chat Bubbles', StoreCategory.bubble, '💬'),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String title, StoreCategory cat, String emoji) {
    final isSelected = _selectedCategory == cat;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = cat;
            final firstInCat = catalog.firstWhere((i) => i.category == cat);
            _previewItem = firstInCat;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gemEmerald.withValues(alpha: 0.25) : Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gemEmerald : Colors.white12,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogGrid({required bool isMall}) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final filteredList = catalog.where((item) {
          if (item.category != _selectedCategory) return false;
          final isOwned = _ownedItemIds.contains(item.id);
          if (isMall) {
            return true; // Show all in Mall
          } else {
            return isOwned; // Only owned in Backpack
          }
        }).toList();

        if (filteredList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 48),
                const SizedBox(height: 12),
                Text(
                  isMall
                      ? 'No items available in this category.'
                      : 'No items in backpack yet.\nVisit Mall to unlock!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                if (!isMall) ...[
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gemEmerald,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Browse Mall'),
                  ),
                ],
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final item = filteredList[index];
            final isOwned = _ownedItemIds.contains(item.id);
            final isEquipped = _isItemEquipped(item);
            final isSelectedForPreview = _previewItem?.id == item.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _previewItem = item;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelectedForPreview
                      ? const Color(0xFF13362A)
                      : const Color(0xFF0B2118),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelectedForPreview
                        ? AppColors.gemEmerald
                        : item.primaryColor.withValues(alpha: 0.25),
                    width: isSelectedForPreview ? 1.8 : 1,
                  ),
                  boxShadow: [
                    if (isSelectedForPreview)
                      BoxShadow(
                        color: AppColors.gemEmerald.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Item Icon & Badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                item.primaryColor.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Text(
                          item.iconEmoji,
                          style: const TextStyle(fontSize: 34),
                        ),
                        if (isEquipped)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.gemEmerald,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.black, size: 12),
                            ),
                          ),
                      ],
                    ),

                    // Name & Description
                    Column(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.duration,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    // Action Button (Equip or Buy)
                    SizedBox(
                      width: double.infinity,
                      child: isOwned
                          ? OutlinedButton(
                              onPressed: () => _toggleEquip(item),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isEquipped
                                    ? AppColors.gemEmerald.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: isEquipped ? AppColors.gemEmerald : Colors.white24,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isEquipped ? 'Equipped' : 'Equip',
                                style: TextStyle(
                                  color: isEquipped ? AppColors.gemEmerald : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _buyItem(item, profileState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.monetization_on, color: Colors.black, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.coinPrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
