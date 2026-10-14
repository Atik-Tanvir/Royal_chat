import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int currentTabIndex;
  final int unreadMessagesCount;

  const NavigationState({
    this.currentTabIndex = 1, // Default to Party Tab (index 1) or Games (index 0)
    this.unreadMessagesCount = 6,
  });

  NavigationState copyWith({
    int? currentTabIndex,
    int? unreadMessagesCount,
  }) {
    return NavigationState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
    );
  }

  @override
  List<Object> get props => [currentTabIndex, unreadMessagesCount];
}
