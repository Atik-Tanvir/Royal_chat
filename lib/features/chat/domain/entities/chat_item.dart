import 'package:equatable/equatable.dart';

enum ChatType {
  system,
  strangers,
  direct,
}

class ChatItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final int unreadCount;
  final ChatType type;
  final String? avatarUrl;

  const ChatItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.unreadCount,
    required this.type,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        timestamp,
        unreadCount,
        type,
        avatarUrl,
      ];
}
