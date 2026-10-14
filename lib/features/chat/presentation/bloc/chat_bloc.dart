import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_item.dart';
import '../../domain/entities/message_bubble.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(_createInitialState()) {
    on<LoadChatsEvent>((event, emit) {
      emit(_createInitialState());
    });

    on<SendDirectMessageEvent>(_onSendDirectMessage);
    on<MarkChatAsReadEvent>(_onMarkChatAsRead);
  }

  static ChatState _createInitialState() {
    final chats = [
      const ChatItem(
        id: 'system_msg',
        title: 'System Message',
        subtitle: 'Dear user: 2,000 coins of Sign-in reward on 14/10/202...',
        timestamp: '20:28',
        unreadCount: 5,
        type: ChatType.system,
      ),
      const ChatItem(
        id: 'strangers_msg',
        title: 'Stranger Messages',
        subtitle: 'User31823345: Hello! Hope today\'s treating you kindly 🌷',
        timestamp: 'Monday',
        unreadCount: 1,
        type: ChatType.strangers,
      ),
      const ChatItem(
        id: 'user_yanboyy',
        title: 'yanboyy',
        subtitle: 'Thanks for the gift in the party room! 🚀',
        timestamp: '19:40',
        unreadCount: 0,
        type: ChatType.direct,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
      ),
    ];

    final Map<String, List<MessageBubble>> messages = {
      'system_msg': [
        MessageBubble(
          id: 'sys_1',
          senderId: 'System',
          text: 'Dear user: 2,000 coins of Sign-in reward on 14/10/2026 has been added to your wallet!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isMe: false,
        ),
      ],
      'strangers_msg': [
        MessageBubble(
          id: 'str_1',
          senderId: 'User31823345',
          text: 'Hello! Hope today\'s treating you kindly 🌷',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isMe: false,
        ),
      ],
      'user_yanboyy': [
        MessageBubble(
          id: 'yb_1',
          senderId: 'yanboyy',
          text: 'Thanks for the gift in the party room! 🚀',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isMe: false,
        ),
      ],
    };

    return ChatState(chats: chats, messagesMap: messages);
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
