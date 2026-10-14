import '../../domain/entities/party_room.dart';
import '../../domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  final List<PartyRoom> _rooms = [
    // Lucky Number rooms
    const PartyRoom(
      id: 'room_101',
      title: 'Zzzzzzzzzz party vibe',
      hostName: 'Zzzzzzzzzz...',
      hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      countryFlag: '🇵🇭',
      onlineCount: 18,
      category: 'Lucky Number',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      ],
    ),
    const PartyRoom(
      id: 'room_102',
      title: '💖 ANG...',
      hostName: '💖 ANG...',
      hostAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      countryFlag: '🇧🇩',
      onlineCount: 22,
      category: 'Lucky Number',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
      ],
    ),
    const PartyRoom(
      id: 'room_103',
      title: 'Ayesha Live Party',
      hostName: 'Ayesha4357',
      hostAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      countryFlag: '🇧🇩',
      onlineCount: 29,
      category: 'Lucky Number',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      ],
    ),

    // Lucky Race rooms
    const PartyRoom(
      id: 'room_201',
      title: '˚ʚ💜S el€... vibes',
      hostName: '˚ʚ💜S el€...',
      hostAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      countryFlag: '🇨🇴',
      onlineCount: 14,
      category: 'Lucky Race',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      ],
    ),
    const PartyRoom(
      id: 'room_202',
      title: 'Nörh✿Mär! Chill Space',
      hostName: 'Nörh✿Mär!...',
      hostAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      countryFlag: '🇵🇭',
      onlineCount: 35,
      category: 'Lucky Race',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      ],
    ),
    const PartyRoom(
      id: 'room_203',
      title: 'JASMINE Musical Cafe',
      hostName: 'JASMINE😊',
      hostAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      countryFlag: '🇧🇩',
      onlineCount: 42,
      category: 'Lucky Race',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
      ],
    ),

    // Chatroom rooms
    const PartyRoom(
      id: 'room_301',
      title: 'Late Night Talk',
      hostName: 'Bella_Girl',
      hostAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      countryFlag: '🇵🇭',
      onlineCount: 19,
      category: 'Chatroom',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      ],
    ),
    const PartyRoom(
      id: 'room_302',
      title: 'Royal Crown Chill',
      hostName: 'Queen_K',
      hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      countryFlag: '🇲🇾',
      onlineCount: 13,
      category: 'Chatroom',
      seatedAvatars: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
      ],
    ),
  ];

  @override
  Future<List<PartyRoom>> getPartyRooms({String? category, String? country}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (category != null && category != 'All') {
      return _rooms.where((r) => r.category == category).toList();
    }
    return _rooms;
  }

  @override
  Future<PartyRoom> createRoom({required String title, required String category}) async {
    final newRoom = PartyRoom(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      hostName: 'User30961573',
      hostAvatar: '',
      countryFlag: '🇧🇩',
      onlineCount: 1,
      category: category,
      seatedAvatars: const [],
      isLive: true,
    );
    _rooms.insert(0, newRoom);
    return newRoom;
  }
}
