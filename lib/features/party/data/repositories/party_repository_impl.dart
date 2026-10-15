import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/party_room.dart';
import '../../domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  @override
  Future<List<PartyRoom>> getPartyRooms({String? category, String? country}) async {
    try {
      var query = SupabaseConfig.client.from('rooms').select();
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.eq('category', category);
      }
      if (country != null && country.isNotEmpty && country != 'All') {
        query = query.eq('country', country);
      }
      final response = await query.order('created_at', ascending: false);
      if (response.isNotEmpty) {
        return (response as List).map((row) {
          final seatedAvatarsRaw = row['seated_avatars'];
          List<String> seated = [];
          if (seatedAvatarsRaw is List) {
            seated = seatedAvatarsRaw.map((e) => e.toString()).toList();
          }

          return PartyRoom(
            id: row['id'] as String,
            title: row['title'] as String? ?? 'Live Party Room',
            hostName: row['host_name'] as String? ?? 'Host',
            hostAvatar: (row['host_avatar'] as String?)?.isNotEmpty == true
                ? row['host_avatar'] as String
                : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            countryFlag: row['country_flag'] as String? ?? '🇧🇩',
            onlineCount: (row['online_count'] as num?)?.toInt() ?? 1,
            category: row['category'] as String? ?? 'Lucky Number',
            seatedAvatars: seated,
            isLive: row['status'] == 'live',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('PartyRepository: Supabase fetch error: $e');
    }

    return const [];
  }

  @override
  Future<PartyRoom> createRoom({required String title, required String category}) async {
    final user = SupabaseConfig.client.auth.currentUser;
    final hostName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.email?.split('@').first ??
        'RoyalHost';
    final hostAvatar = user?.userMetadata?['avatar_url'] as String? ?? '';

    final newId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    final newRoom = PartyRoom(
      id: newId,
      title: title,
      hostName: hostName,
      hostAvatar: hostAvatar.isNotEmpty
          ? hostAvatar
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      countryFlag: '🇧🇩',
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
        'country': 'Bangladesh',
        'country_flag': newRoom.countryFlag,
        'online_count': newRoom.onlineCount,
        'status': 'live',
      });

      // Automatically create 8 seats in room_seats table
      for (int i = 0; i < 8; i++) {
        await SupabaseConfig.client.from('room_seats').insert({
          'room_id': newRoom.id,
          'seat_index': i,
          'user_id': i == 0 ? (user?.id ?? 'host') : '',
          'user_name': i == 0 ? hostName : '',
          'avatar_url': i == 0 ? hostAvatar : '',
          'is_muted': false,
        });
      }
    } catch (e) {
      debugPrint('PartyRepository: Supabase insert error: $e');
    }

    return newRoom;
  }
}
