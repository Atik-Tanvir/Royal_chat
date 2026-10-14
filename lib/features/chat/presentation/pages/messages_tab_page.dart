import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../domain/entities/chat_item.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import 'conversation_page.dart';
import 'system_messages_page.dart';

class MessagesTabPage extends StatelessWidget {
  const MessagesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GemgalaBackground(
      child: Column(
        children: [
          // Top Bar matching Screenshot 2
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const RoyalBrandLogo(size: 26),
                const SizedBox(width: 10),
                Text(
                  'Messages',
                  style: AppTextStyles.headerLarge.copyWith(fontSize: 20),
                ),
                const Spacer(),
                // Contact / Friend directory icon with coin
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.goldCoin,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.goldCoin,
                  size: 28,
                ),
              ],
            ),
          ),

          // Yellow Notification Ribbon matching Screenshot 2
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

          // Chat items list
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.chats.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.05),
                    height: 1,
                    indent: 76,
                  ),
                  itemBuilder: (context, index) {
                    final chat = state.chats[index];
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
        if (chat.title == 'System Message') {
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
      // Matching Screenshot 2: Light mint circular background with bell icon
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
      // Matching Screenshot 2: Circular light green target icon
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

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgMidGreen,
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}
