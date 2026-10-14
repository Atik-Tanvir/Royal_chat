import 'package:equatable/equatable.dart';

abstract class PartyEvent extends Equatable {
  const PartyEvent();

  @override
  List<Object?> get props => [];
}

class FetchPartyRoomsEvent extends PartyEvent {
  final String? category;
  final String? country;

  const FetchPartyRoomsEvent({this.category, this.country});

  @override
  List<Object?> get props => [category, country];
}

class SelectSubTabEvent extends PartyEvent {
  final String subTab; // 'Follow', 'Party', 'Chat', 'Top'

  const SelectSubTabEvent(this.subTab);

  @override
  List<Object?> get props => [subTab];
}

class SelectCategoryFilterEvent extends PartyEvent {
  final String category;

  const SelectCategoryFilterEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class CreateNewRoomEvent extends PartyEvent {
  final String title;
  final String category;

  const CreateNewRoomEvent({required this.title, required this.category});

  @override
  List<Object?> get props => [title, category];
}
