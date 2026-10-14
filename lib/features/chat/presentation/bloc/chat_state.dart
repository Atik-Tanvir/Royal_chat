import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_item.dart';
import '../../domain/entities/message_bubble.dart';

class ChatState extends Equatable {
  final List<ChatItem> chats;
  final Map<String, List<MessageBubble>> messagesMap;
  final bool isNotificationWarningVisible;

  const ChatState({
    this.chats = const [],
    this.messagesMap = const {},
    this.isNotificationWarningVisible = true,
  });

  ChatState copyWith({
    List<ChatItem>? chats,
    Map<String, List<MessageBubble>>? messagesMap,
    bool? isNotificationWarningVisible,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messagesMap: messagesMap ?? this.messagesMap,
      isNotificationWarningVisible:
          isNotificationWarningVisible ?? this.isNotificationWarningVisible,
    );
  }

  @override
  List<Object?> get props => [chats, messagesMap, isNotificationWarningVisible];
}
