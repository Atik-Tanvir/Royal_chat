import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../widgets/custom_bottom_nav_bar.dart';

import '../../../games/presentation/pages/games_tab_page.dart';
import '../../../party/presentation/pages/party_tab_page.dart';
import '../../../moments/presentation/pages/moments_tab_page.dart';
import '../../../chat/presentation/pages/messages_tab_page.dart';
import '../../../profile/presentation/pages/profile_tab_page.dart';
import '../../../profile/presentation/widgets/edit_profile_sheet.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  static const List<Widget> _pages = [
    GamesTabPage(),
    PartyTabPage(),
    MomentsTabPage(),
    MessagesTabPage(),
    ProfileTabPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialProfileSetup();
    });
  }

  Future<void> _checkInitialProfileSetup() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    if (!AuthSessionManager.isProfileSetupCompleted) {
      EditProfileSheet.show(context, isInitialSetup: true);
    }
  }

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
