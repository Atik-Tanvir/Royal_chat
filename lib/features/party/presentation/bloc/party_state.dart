import 'package:equatable/equatable.dart';
import '../../domain/entities/party_room.dart';

class PartyState extends Equatable {
  final List<PartyRoom> allRooms;
  final List<PartyRoom> filteredRooms;
  final String selectedSubTab;
  final String selectedCategory;
  final bool isLoading;
  final String? errorMessage;

  const PartyState({
    this.allRooms = const [],
    this.filteredRooms = const [],
    this.selectedSubTab = 'Party',
    this.selectedCategory = 'All',
    this.isLoading = false,
    this.errorMessage,
  });

  PartyState copyWith({
    List<PartyRoom>? allRooms,
    List<PartyRoom>? filteredRooms,
    String? selectedSubTab,
    String? selectedCategory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PartyState(
      allRooms: allRooms ?? this.allRooms,
      filteredRooms: filteredRooms ?? this.filteredRooms,
      selectedSubTab: selectedSubTab ?? this.selectedSubTab,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allRooms,
        filteredRooms,
        selectedSubTab,
        selectedCategory,
        isLoading,
        errorMessage,
      ];
}
