import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/party_room.dart';
import '../../domain/repositories/party_repository.dart';
import 'party_event.dart';
import 'party_state.dart';

class PartyBloc extends Bloc<PartyEvent, PartyState> {
  final PartyRepository repository;

  PartyBloc({required this.repository}) : super(const PartyState()) {
    on<FetchPartyRoomsEvent>(_onFetchPartyRooms);
    on<SelectSubTabEvent>(_onSelectSubTab);
    on<SelectCategoryFilterEvent>(_onSelectCategoryFilter);
    on<CreateNewRoomEvent>(_onCreateNewRoom);
  }

  Future<void> _onFetchPartyRooms(
    FetchPartyRoomsEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final rooms = await repository.getPartyRooms();
      emit(state.copyWith(
        allRooms: rooms,
        filteredRooms: _filter(rooms, state.selectedCategory),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSelectSubTab(
    SelectSubTabEvent event,
    Emitter<PartyState> emit,
  ) {
    emit(state.copyWith(selectedSubTab: event.subTab));
  }

  void _onSelectCategoryFilter(
    SelectCategoryFilterEvent event,
    Emitter<PartyState> emit,
  ) {
    final filtered = _filter(state.allRooms, event.category);
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredRooms: filtered,
    ));
  }

  Future<void> _onCreateNewRoom(
    CreateNewRoomEvent event,
    Emitter<PartyState> emit,
  ) async {
    try {
      final newRoom = await repository.createRoom(
        title: event.title,
        category: event.category,
      );
      final updatedList = [newRoom, ...state.allRooms];
      emit(state.copyWith(
        allRooms: updatedList,
        filteredRooms: _filter(updatedList, state.selectedCategory),
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  List<PartyRoom> _filter(List<PartyRoom> rooms, String category) {
    if (category == 'All') return rooms;
    return rooms.where((r) => r.category == category).toList();
  }
}
