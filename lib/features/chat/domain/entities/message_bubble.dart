import 'package:equatable/equatable.dart';

class MessageBubble extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  const MessageBubble({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  @override
  List<Object?> get props => [id, senderId, text, timestamp, isMe];
}
