import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(currentTabIndex: 1)) {
    on<TabChangedEvent>((event, emit) {
      emit(state.copyWith(currentTabIndex: event.tabIndex));
    });
  }
}
