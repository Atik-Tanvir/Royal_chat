import '../entities/party_room.dart';

abstract class PartyRepository {
  Future<List<PartyRoom>> getPartyRooms({String? category, String? country});
  Future<PartyRoom> createRoom({required String title, required String category});
}
