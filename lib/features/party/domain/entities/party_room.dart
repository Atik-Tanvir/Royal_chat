import 'package:equatable/equatable.dart';

class PartyRoom extends Equatable {
  final String id;
  final String title;
  final String hostName;
  final String hostAvatar;
  final String countryFlag;
  final int onlineCount;
  final String category; // 'Lucky Number', 'Lucky Race', 'Chatroom', 'PK'
  final List<String> seatedAvatars;
  final bool isLive;
  final bool isLocked;

  const PartyRoom({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostAvatar,
    required this.countryFlag,
    required this.onlineCount,
    required this.category,
    required this.seatedAvatars,
    this.isLive = true,
    this.isLocked = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        hostName,
        hostAvatar,
        countryFlag,
        onlineCount,
        category,
        seatedAvatars,
        isLive,
        isLocked,
      ];
}
