import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../domain/entities/chat_item.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import 'conversation_page.dart';
import 'system_messages_page.dart';

class MessagesTabPage extends StatefulWidget {
  const MessagesTabPage({super.key});

  @override
  State<MessagesTabPage> createState() => _MessagesTabPageState();
}

class _MessagesTabPageState extends State<MessagesTabPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddFriendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddFriendOrStartChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: Column(
        children: [
          // Top Bar with functional Search and Add Friend buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _isSearching
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 24),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      ),
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: AppColors.goldCoin.withOpacity(0.6)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            onChanged: (val) {
                              setState(() => _searchQuery = val.trim());
                            },
                            decoration: InputDecoration(
                              hintText: 'Search chats or friends...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _searchQuery = '';
                                          _searchController.clear();
                                        });
                                      },
                                      child: const Icon(Icons.clear_rounded,
                                          color: Colors.white70, size: 18),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _openAddFriendSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldCoin.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: AppColors.goldCoin,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const RoyalBrandLogo(size: 26),
                      const SizedBox(width: 10),
                      Text(
                        'Messages',
                        style: AppTextStyles.headerLarge.copyWith(fontSize: 20),
                      ),
                      const Spacer(),
                      // Functional Add Friend / Start Chat Button
                      GestureDetector(
                        onTap: () => _openAddFriendSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: AppColors.goldCoin,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Functional Search Button
                      GestureDetector(
                        onTap: () {
                          setState(() => _isSearching = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppColors.goldCoin,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Notification Ribbon matching Screenshot
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF9A825),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Message notification is turned off',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),

          // Chat items list with Search Filtering
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final filteredChats = _searchQuery.isEmpty
                    ? state.chats
                    : state.chats.where((chat) {
                        final titleMatch = chat.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                        final subMatch = chat.subtitle
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                        return titleMatch || subMatch;
                      }).toList();

                if (filteredChats.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSearching
                                ? Icons.search_off_rounded
                                : Icons.chat_bubble_outline_rounded,
                            color: Colors.white38,
                            size: 54,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isSearching
                                ? 'No chats found matching "$_searchQuery"'
                                : 'No conversations yet',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _openAddFriendSheet(context),
                            icon: const Icon(Icons.person_add_rounded,
                                size: 18, color: Colors.black87),
                            label: const Text(
                              'Search Community Friends',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldCoin,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredChats.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.05),
                    height: 1,
                    indent: 76,
                  ),
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return _buildChatListItem(context, chat);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, ChatItem chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        if (chat.title == 'System Messages' || chat.title == 'System Message') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SystemMessagesPage(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConversationPage(chat: chat),
            ),
          );
        }
      },
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildLeadingAvatar(chat),
          if (chat.unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.badgePink,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.title,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            chat.timestamp,
            style: AppTextStyles.caption.copyWith(color: Colors.white54),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar(ChatItem chat) {
    if (chat.type == ChatType.system) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFC7F9E2),
        ),
        child: const Center(
          child: Icon(
            Icons.notifications_active_rounded,
            color: Color(0xFF0F9D58),
            size: 26,
          ),
        ),
      );
    } else if (chat.type == ChatType.strangers) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFC7F9E2),
        ),
        child: Center(
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldCoin,
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F9D58),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CustomAvatar(
      imageUrl: chat.avatarUrl ?? '',
      fallbackName: chat.title,
      radius: 25,
    );
  }
}

/// Bottom Sheet for Searching Friends, finding User IDs, and starting new conversations
class _AddFriendOrStartChatSheet extends StatefulWidget {
  const _AddFriendOrStartChatSheet();

  @override
  State<_AddFriendOrStartChatSheet> createState() =>
      _AddFriendOrStartChatSheetState();
}

class _AddFriendOrStartChatSheetState
    extends State<_AddFriendOrStartChatSheet> {
  final TextEditingController _queryController = TextEditingController();
  String _filter = '';

  // Recommended / Active starter users so users always have friends to chat with
  final List<Map<String, String>> _starterUsers = [
    {
      'id': 'user_yanboyy',
      'name': 'yanboyy',
      'handle': '@yanboyy_ctg',
      'avatar': 'royal_avatar://YB:E65100',
      'flag': '🇧🇩',
      'status': 'Lucky Wheel Player',
    },
    {
      'id': 'user_sadia',
      'name': 'SadiaQueen',
      'handle': '@sadia_queen',
      'avatar': 'royal_avatar://SQ:8E24AA',
      'flag': '🇧🇩',
      'status': 'Voice Room Host',
    },
    {
      'id': 'user_arafat',
      'name': 'Arafat_BD',
      'handle': '@arafat_dhaka',
      'avatar': 'royal_avatar://AB:00897B',
      'flag': '🇧🇩',
      'status': '7 Up 7 Down Master',
    },
    {
      'id': 'user_tanvir',
      'name': 'Tanvir_Pro',
      'handle': '@tanvir_bd',
      'avatar': 'royal_avatar://TP:1565C0',
      'flag': '🇧🇩',
      'status': 'Color Spin Expert',
    },
    {
      'id': 'user_maya',
      'name': 'Maya_Chowdhury',
      'handle': '@maya_sylhet',
      'avatar': 'royal_avatar://MC:C2185B',
      'flag': '🇧🇩',
      'status': 'Party Host VIP',
    },
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _startChatWithUser(Map<String, String> user) {
    final chat = ChatItem(
      id: user['id']!,
      title: user['name']!,
      subtitle: 'Say hi to ${user['name']} 👋',
      timestamp: 'Now',
      unreadCount: 0,
      type: ChatType.direct,
      avatarUrl: user['avatar'],
    );

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(chat: chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = AuthSessionManager.currentUserId ?? 'user_shihab_102';

    final filtered = _filter.isEmpty
        ? _starterUsers
        : _starterUsers.where((u) {
            final q = _filter.toLowerCase();
            return u['name']!.toLowerCase().contains(q) ||
                u['handle']!.toLowerCase().contains(q) ||
                u['id']!.toLowerCase().contains(q);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF13231B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldCoin.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.goldCoin,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Chat / Add Friend',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Find users by ID, Name, or Handle',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User's own ID Card with Copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_rounded,
                    color: AppColors.goldCoin, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your User ID (Share to receive chats)',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      Text(
                        myId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: myId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ User ID copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.gemEmerald,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldCoin.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.goldCoin.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded,
                            size: 14, color: AppColors.goldCoin),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: AppColors.goldCoin,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _queryController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: (val) {
              setState(() => _filter = val.trim());
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              hintText: 'Search User ID or Name...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.goldCoin),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // List Header
          const Text(
            'Recommended & Active Community Members',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Users List
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.white.withOpacity(0.06), height: 1),
              itemBuilder: (context, idx) {
                final user = filtered[idx];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  leading: Stack(
                    children: [
                      CustomAvatar(
                        imageUrl: user['avatar']!,
                        fallbackName: user['name']!,
                        radius: 22,
                        countryFlag: user['flag'],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.gemEmerald,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF13231B), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    user['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${user['handle']} • ${user['status']}',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _startChatWithUser(user),
                    icon: const Icon(Icons.chat_bubble_rounded,
                        size: 15, color: Colors.black87),
                    label: const Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldCoin,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
