import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatsEvent extends ChatEvent {}

class SendDirectMessageEvent extends ChatEvent {
  final String chatId;
  final String text;

  const SendDirectMessageEvent({required this.chatId, required this.text});

  @override
  List<Object?> get props => [chatId, text];
}

class MarkChatAsReadEvent extends ChatEvent {
  final String chatId;

  const MarkChatAsReadEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}
