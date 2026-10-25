import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/chat_item.dart';
import '../../domain/entities/message_bubble.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  RealtimeChannel? _dmChannel;
  RealtimeChannel? _sysChannel;

  ChatBloc() : super(_createInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<SendDirectMessageEvent>(_onSendDirectMessage);
    on<MarkChatAsReadEvent>(_onMarkChatAsRead);

    // Initial dynamic load from Supabase
    add(LoadChatsEvent());
    _subscribeToRealtime();
  }

  static ChatState _createInitialState() {
    return const ChatState(chats: [], messagesMap: {});
  }

  @override
  Future<void> close() {
    _dmChannel?.unsubscribe();
    _sysChannel?.unsubscribe();
    return super.close();
  }

  void _subscribeToRealtime() {
    final currentUserId = AuthSessionManager.currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return;

    try {
      _dmChannel = SupabaseConfig.client
          .channel('public:direct_messages_$currentUserId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'direct_messages',
            callback: (_) {
              add(LoadChatsEvent());
            },
          )
          .subscribe();

      _sysChannel = SupabaseConfig.client
          .channel('public:system_messages_chat')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'system_messages',
            callback: (_) {
              add(LoadChatsEvent());
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[ChatBloc] Realtime subscription error: $e');
    }
  }

  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    try {
      final currentUserId = AuthSessionManager.currentUserId ?? '';

      // 1. Fetch live system messages from Supabase
      List<MessageBubble> sysBubbles = [];
      String lastSysContent = 'Welcome to Royal Chat Live!';
      int sysUnreadCount = 0;

      try {
        final sysRes = await SupabaseConfig.client
            .from('system_messages')
            .select()
            .order('created_at', ascending: false);

        if (sysRes.isNotEmpty) {
          sysBubbles = (sysRes as List).map((row) {
            final isRead = row['is_read'] as bool? ?? false;
            if (!isRead) sysUnreadCount++;
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
      } catch (e) {
        debugPrint('[ChatBloc] Fetch system_messages error: $e');
      }

      // 2. Fetch direct messages from Supabase for current user
      final Map<String, List<MessageBubble>> dynamicMessages = {
        'system_msg': sysBubbles,
      };

      if (currentUserId.isNotEmpty) {
        try {
          final dmRes = await SupabaseConfig.client
              .from('direct_messages')
              .select()
              .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
              .order('created_at', ascending: true);

          for (final row in dmRes) {
            final sId = row['sender_id']?.toString() ?? '';
            final rId = row['receiver_id']?.toString() ?? '';
            final otherUserId = sId == currentUserId ? rId : sId;
            final chatId = 'user_$otherUserId';

            final isMe = sId == currentUserId;
            final bubble = MessageBubble(
              id: row['id']?.toString() ?? 'dm_${DateTime.now().millisecondsSinceEpoch}',
              senderId: isMe ? 'Me' : otherUserId,
              text: row['message_text']?.toString() ?? '',
              timestamp: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
              isMe: isMe,
            );

            dynamicMessages.putIfAbsent(chatId, () => []).add(bubble);
          }
        } catch (e) {
          debugPrint('[ChatBloc] Fetch direct_messages error: $e');
        }
      }

      // 3. Fetch active community profiles to populate chat list
      final List<ChatItem> dynamicChats = [
        ChatItem(
          id: 'system_msg',
          title: 'System Messages',
          subtitle: lastSysContent,
          timestamp: 'Live',
          unreadCount: sysUnreadCount,
          type: ChatType.system,
        ),
      ];

      try {
        final profilesRes = await SupabaseConfig.client
            .from('profiles')
            .select()
            .limit(10);

        for (var p in profilesRes as List) {
          final pid = p['id']?.toString() ?? '';
          if (pid == currentUserId) continue;

          final name = p['nickname']?.toString() ?? 'Royal Friend';
          final avatar = p['avatar_url']?.toString() ?? '';
          final chatId = 'user_$pid';

          final conversation = dynamicMessages[chatId] ?? [];
          final lastMsg = conversation.isNotEmpty ? conversation.last : null;
          final subtitle = lastMsg != null
              ? (lastMsg.isMe ? 'You: ${lastMsg.text}' : lastMsg.text)
              : 'Tap to start conversation';
          final timestamp = lastMsg != null
              ? '${lastMsg.timestamp.hour.toString().padLeft(2, '0')}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}'
              : 'Online';

          dynamicChats.add(
            ChatItem(
              id: chatId,
              title: name,
              subtitle: subtitle,
              timestamp: timestamp,
              unreadCount: 0,
              type: ChatType.direct,
              avatarUrl: avatar.isNotEmpty ? avatar : null,
            ),
          );
        }
      } catch (e) {
        debugPrint('[ChatBloc] Fetch profiles error: $e');
      }

      emit(state.copyWith(chats: dynamicChats, messagesMap: dynamicMessages));
    } catch (e) {
      debugPrint('[ChatBloc] Load error: $e');
    }
  }

  Future<void> _onSendDirectMessage(SendDirectMessageEvent event, Emitter<ChatState> emit) async {
    final currentUserId = AuthSessionManager.currentUserId ?? 'guest';
    final targetUserId = event.chatId.startsWith('user_')
        ? event.chatId.replaceFirst('user_', '')
        : event.chatId;

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

    // Persist to Supabase direct_messages table
    try {
      await SupabaseConfig.client.from('direct_messages').insert({
        'sender_id': currentUserId,
        'receiver_id': targetUserId,
        'message_text': event.text,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('[ChatBloc] Supabase insert direct_message error: $e');
    }
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
