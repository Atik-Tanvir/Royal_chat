import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../widgets/custom_bottom_nav_bar.dart';

import '../../../games/presentation/pages/games_tab_page.dart';
import '../../../party/presentation/pages/party_tab_page.dart';
import '../../../moments/presentation/pages/moments_tab_page.dart';
import '../../../chat/presentation/pages/messages_tab_page.dart';
import '../../../profile/presentation/pages/profile_tab_page.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  static const List<Widget> _pages = [
    GamesTabPage(),
    PartyTabPage(),
    MomentsTabPage(),
    MessagesTabPage(),
    ProfileTabPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentTabIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: state.currentTabIndex,
            unreadCount: state.unreadMessagesCount,
            onTap: (index) {
              context.read<NavigationBloc>().add(TabChangedEvent(index));
            },
          ),
        );
      },
    );
  }
}
