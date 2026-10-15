import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/chat_item.dart';
import '../../domain/entities/message_bubble.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(_createInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<SendDirectMessageEvent>(_onSendDirectMessage);
    on<MarkChatAsReadEvent>(_onMarkChatAsRead);

    // Initial dynamic load from Supabase
    add(LoadChatsEvent());
  }

  static ChatState _createInitialState() {
    return const ChatState(chats: [], messagesMap: {});
  }

  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    try {
      // 1. Fetch live system messages from Supabase
      final sysRes = await SupabaseConfig.client
          .from('system_messages')
          .select()
          .order('created_at', ascending: false);

      List<MessageBubble> sysBubbles = [];
      String lastSysContent = 'Welcome to Royal Chat Live!';
      int unreadCount = 0;

      if (sysRes.isNotEmpty) {
        sysBubbles = (sysRes as List).map((row) {
          final isRead = row['is_read'] as bool? ?? false;
          if (!isRead) unreadCount++;
          return MessageBubble(
            id: row['id']?.toString() ?? 'sys_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'System',
            text: '${row['title'] ?? 'Notification'}: ${row['content'] ?? ''}',
            timestamp: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
            isMe: false,
          );
        }).toList();

        if (sysBubbles.isNotEmpty) {
          lastSysContent = sysBubbles.first.text;
        }
      }

      // 2. Fetch active community profiles for direct chats
      final profilesRes = await SupabaseConfig.client
          .from('profiles')
          .select()
          .limit(5);

      final List<ChatItem> dynamicChats = [
        ChatItem(
          id: 'system_msg',
          title: 'System Messages',
          subtitle: lastSysContent,
          timestamp: 'Just now',
          unreadCount: unreadCount,
          type: ChatType.system,
        ),
      ];

      final Map<String, List<MessageBubble>> dynamicMessages = {
        'system_msg': sysBubbles,
      };

      if (profilesRes.isNotEmpty) {
        for (var p in profilesRes as List) {
          final pid = p['id']?.toString() ?? '';
          final currentUserId = AuthSessionManager.currentUserId;
          if (pid == currentUserId) continue;

          final name = p['nickname']?.toString() ?? 'Royal Friend';
          final avatar = p['avatar_url']?.toString() ?? '';
          final chatId = 'user_$pid';

          dynamicChats.add(
            ChatItem(
              id: chatId,
              title: name,
              subtitle: 'Active in Royal Chat Live',
              timestamp: 'Online',
              unreadCount: 0,
              type: ChatType.direct,
              avatarUrl: avatar.isNotEmpty ? avatar : null,
            ),
          );

          dynamicMessages[chatId] = [
            MessageBubble(
              id: 'msg_welcome_$pid',
              senderId: name,
              text: 'Hey! Welcome to Royal Chat Live! Let\'s connect in party rooms 🎤✨',
              timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
              isMe: false,
            ),
          ];
        }
      }

      emit(state.copyWith(chats: dynamicChats, messagesMap: dynamicMessages));
    } catch (e) {
      debugPrint('ChatBloc Supabase load error: $e');
    }
  }

  void _onSendDirectMessage(SendDirectMessageEvent event, Emitter<ChatState> emit) {
    final currentList = state.messagesMap[event.chatId] ?? [];
    final newMessage = MessageBubble(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'Me',
      text: event.text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    final updatedMap = Map<String, List<MessageBubble>>.from(state.messagesMap);
    updatedMap[event.chatId] = [...currentList, newMessage];

    // Update last subtitle in chat list
    final updatedChats = state.chats.map((c) {
      if (c.id == event.chatId) {
        return ChatItem(
          id: c.id,
          title: c.title,
          subtitle: 'You: ${event.text}',
          timestamp: 'Just now',
          unreadCount: 0,
          type: c.type,
          avatarUrl: c.avatarUrl,
        );
      }
      return c;
    }).toList();

    emit(state.copyWith(messagesMap: updatedMap, chats: updatedChats));
  }

  void _onMarkChatAsRead(MarkChatAsReadEvent event, Emitter<ChatState> emit) {
    final updatedChats = state.chats.map((c) {
      if (c.id == event.chatId) {
        return ChatItem(
          id: c.id,
          title: c.title,
          subtitle: c.subtitle,
          timestamp: c.timestamp,
          unreadCount: 0,
          type: c.type,
          avatarUrl: c.avatarUrl,
        );
      }
      return c;
    }).toList();

    emit(state.copyWith(chats: updatedChats));
  }
}
