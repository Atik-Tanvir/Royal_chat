import 'package:flutter/foundation.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/party_room.dart';
import '../../domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
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
        return (response as List).map((row) {
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
      }
    } catch (e) {
      debugPrint('[PartyRepository] Supabase fetch error: $e');
    }

    return const [];
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
