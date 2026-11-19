import 'package:flutter/foundation.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/party_room.dart';
import '../../domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  static const List<PartyRoom> _fallbackRooms = [
    // 1. Lucky Number
    PartyRoom(
      id: 'room_101',
      title: 'Zzzzzzzzzz party vibe',
      hostName: 'Zzzzzzzzzz...',
      hostAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
      countryFlag: '🇵🇭',
      onlineCount: 18,
      category: 'Lucky Number',
      seatedAvatars: [
        'royal_avatar://YB:E65100',
        'royal_avatar://SQ:8E24AA',
      ],
      isLive: true,
    ),
    PartyRoom(
      id: 'room_102',
      title: '💖 ANG... VIP Lounge',
      hostName: '💖 ANG...',
      hostAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 24,
      category: 'Lucky Number',
      seatedAvatars: [
        'royal_avatar://SQ:8E24AA',
      ],
      isLive: true,
    ),
    PartyRoom(
      id: 'room_103',
      title: 'Ayesha Chill Party',
      hostName: 'Ayesha4357',
      hostAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 31,
      category: 'Lucky Number',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'room_104',
      title: 'Mega Jackpot 777 🎰',
      hostName: 'Tanvir_Pro',
      hostAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 45,
      category: 'Lucky Number',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'room_105',
      title: 'High Rollers Dice Club 🎲',
      hostName: 'Ali_Khan_PK',
      hostAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 38,
      category: 'Lucky Number',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'room_106',
      title: 'Fortune Wheel VIP 💎',
      hostName: 'Priya_Royal',
      hostAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 52,
      category: 'Lucky Number',
      seatedAvatars: [],
      isLive: true,
    ),

    // 2. Lucky Race (🟨 sports_motorsports / helmet)
    PartyRoom(
      id: 'race_201',
      title: 'Dhaka Nitro Drift 🏎️',
      hostName: 'Racer_Shanto',
      hostAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 28,
      category: 'Lucky Race',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'race_202',
      title: 'Formula Royal GP 🏁',
      hostName: 'Hamza_Speed',
      hostAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 42,
      category: 'Lucky Race',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'race_203',
      title: 'Turbo Speed Challenge ⚡',
      hostName: 'Vikram_Rider',
      hostAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 35,
      category: 'Lucky Race',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'race_204',
      title: 'Night Highway Racers 🌙',
      hostName: 'Fahim_Turbo',
      hostAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 19,
      category: 'Lucky Race',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'race_205',
      title: 'Supercar Apex Club 🏎️',
      hostName: 'Zeeshan_Apex',
      hostAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 61,
      category: 'Lucky Race',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'race_206',
      title: 'Speedway Champions 🏆',
      hostName: 'Rohit_Racer',
      hostAvatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 33,
      category: 'Lucky Race',
      seatedAvatars: [],
      isLive: true,
    ),

    // 3. Chatroom (🟥 forum / chat bubbles)
    PartyRoom(
      id: 'chat_301',
      title: 'Night Adda & Acoustic 🎸',
      hostName: 'Nabila_Sings',
      hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 64,
      category: 'Chatroom',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'chat_302',
      title: 'Late Night Melody ☕',
      hostName: 'Bilal_Acoustic',
      hostAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 48,
      category: 'Chatroom',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'chat_303',
      title: 'Bollywood Chai & Talks 🎶',
      hostName: 'Ananya_Voice',
      hostAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 75,
      category: 'Chatroom',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'chat_304',
      title: 'Friendship Hub Dhaka ☕',
      hostName: 'Sabbir_Host',
      hostAvatar: 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 29,
      category: 'Chatroom',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'chat_305',
      title: 'Sufi Soul Nights 🌙',
      hostName: 'Zahra_Sufi',
      hostAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 53,
      category: 'Chatroom',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'chat_306',
      title: 'Desi Music & Chill 🎧',
      hostName: 'Arjun_Radio',
      hostAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 41,
      category: 'Chatroom',
      seatedAvatars: [],
      isLive: true,
    ),

    // 4. PK (⚡ offline_bolt / lightning)
    PartyRoom(
      id: 'pk_401',
      title: 'Mega PK: Dhaka vs Lahore ⚡',
      hostName: 'Rifat_Boss',
      hostAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 88,
      category: 'PK',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'pk_402',
      title: '1v1 Crown War: Gift Rush 👑',
      hostName: 'Faizan_King',
      hostAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 95,
      category: 'PK',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'pk_403',
      title: 'Royal Gladiator PK Arena ⚔️',
      hostName: 'Rhea_Warrior',
      hostAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 67,
      category: 'PK',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'pk_404',
      title: 'Star Battle Live PK 💥',
      hostName: 'Mehedi_Host',
      hostAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200',
      countryFlag: '🇧🇩',
      onlineCount: 54,
      category: 'PK',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'pk_405',
      title: 'Ultimate Rivalry Showdown 🔥',
      hostName: 'Tariq_Pro',
      hostAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
      countryFlag: '🇵🇰',
      onlineCount: 73,
      category: 'PK',
      seatedAvatars: [],
      isLive: true,
    ),
    PartyRoom(
      id: 'pk_406',
      title: 'Champion Belt PK Clash 🏆',
      hostName: 'Simran_Star',
      hostAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      countryFlag: '🇮🇳',
      onlineCount: 62,
      category: 'PK',
      seatedAvatars: [],
      isLive: true,
    ),
  ];

  @override
  Future<List<PartyRoom>> getPartyRooms({String? category, String? country}) async {
    try {
      var query = SupabaseConfig.client
          .from('rooms')
          .select('*, room_seats(seat_index, user_id, avatar_url)');
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.eq('category', category);
      }
      if (country != null && country.isNotEmpty && country != 'All') {
        query = query.eq('country', country);
      }
      final response = await query.order('created_at', ascending: false);
      if (response.isNotEmpty) {
        final List<PartyRoom> loaded = (response as List).map((row) {
          // Extract real occupied seats from joined room_seats
          final roomSeatsRaw = row['room_seats'];
          final List<String> seated = [];
          if (roomSeatsRaw is List) {
            for (var seat in roomSeatsRaw) {
              final seatIdx = (seat['seat_index'] as num?)?.toInt() ?? 0;
              final uid = seat['user_id']?.toString() ?? '';
              final avatar = seat['avatar_url']?.toString() ?? '';
              if (seatIdx > 0 && uid.isNotEmpty && avatar.isNotEmpty) {
                seated.add(avatar);
              }
            }
          }

          final hostAvatar = (row['host_avatar'] as String?)?.isNotEmpty == true
              ? row['host_avatar'] as String
              : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

          return PartyRoom(
            id: row['id'] as String,
            title: row['title'] as String? ?? 'Live Party Room',
            hostName: row['host_name'] as String? ?? 'Host',
            hostAvatar: hostAvatar,
            countryFlag: row['country_flag'] as String? ?? '🇧🇩',
            onlineCount: (row['online_count'] as num?)?.toInt() ?? 1,
            category: row['category'] as String? ?? 'Lucky Number',
            seatedAvatars: seated,
            isLive: row['status'] == 'live',
          );
        }).toList();

        // Ensure all 4 categories exist; supplement with fallback if any category is missing
        final categoriesPresent = loaded.map((r) => r.category).toSet();
        for (final fb in _fallbackRooms) {
          if (!categoriesPresent.contains(fb.category)) {
            loaded.add(fb);
          }
        }

        return loaded;
      }
    } catch (e) {
      debugPrint('[PartyRepository] Supabase fetch error: $e');
    }

    // Fallback when Supabase query fails or returns empty
    return _fallbackRooms.where((r) {
      if (category != null && category.isNotEmpty && category != 'All' && r.category != category) {
        return false;
      }
      if (country != null && country.isNotEmpty && country != 'All' && !r.countryFlag.contains(country)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<PartyRoom> createRoom({required String title, required String category}) async {
    final currentUserId = AuthSessionManager.currentUserId;
    String hostName = 'Host';
    String hostAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
    String countryFlag = '🇧🇩';
    String country = 'Bangladesh';

    if (currentUserId != null) {
      try {
        final profileRes = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', currentUserId)
            .maybeSingle();

        if (profileRes != null) {
          final nick = profileRes['nickname'] as String?;
          if (nick != null && nick.isNotEmpty) hostName = nick;
          final av = profileRes['avatar_url'] as String?;
          if (av != null && av.isNotEmpty) hostAvatar = av;
          final flag = profileRes['country_flag'] as String?;
          if (flag != null && flag.isNotEmpty) countryFlag = flag;
          final cntry = profileRes['country'] as String?;
          if (cntry != null && cntry.isNotEmpty) country = cntry;
        }
      } catch (e) {
        debugPrint('[PartyRepository] Fetch host profile error: $e');
      }
    }

    final newId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    final newRoom = PartyRoom(
      id: newId,
      title: title,
      hostName: hostName,
      hostAvatar: hostAvatar,
      countryFlag: countryFlag,
      onlineCount: 1,
      category: category,
      seatedAvatars: const [],
      isLive: true,
    );

    try {
      await SupabaseConfig.client.from('rooms').insert({
        'id': newRoom.id,
        'title': newRoom.title,
        'host_id': currentUserId ?? 'developer_demo_user',
        'host_name': newRoom.hostName,
        'host_avatar': newRoom.hostAvatar,
        'category': newRoom.category,
        'country': country,
        'country_flag': newRoom.countryFlag,
        'online_count': newRoom.onlineCount,
        'status': 'live',
      });

      // Batch insert 8 seats in room_seats table in a single query
      final seatsData = List.generate(8, (i) => {
        'room_id': newRoom.id,
        'seat_index': i,
        'user_id': i == 0 ? currentUserId : null,
        'user_name': i == 0 ? hostName : null,
        'avatar_url': i == 0 ? hostAvatar : null,
        'is_muted': false,
      });

      await SupabaseConfig.client.from('room_seats').insert(seatsData);
    } catch (e) {
      debugPrint('[PartyRepository] Supabase insert error: $e');
    }

    return newRoom;
  }
}
