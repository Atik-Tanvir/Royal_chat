import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../features/games/presentation/bloc/block_me_bloc.dart';
import '../features/moments/presentation/bloc/moments_bloc.dart';
import '../features/navigation/presentation/bloc/navigation_bloc.dart';
import '../features/party/data/repositories/party_repository_impl.dart';
import '../features/party/presentation/bloc/party_bloc.dart';
import '../features/party/presentation/bloc/party_event.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';

class GemgalaApp extends StatelessWidget {
  const GemgalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final partyRepository = PartyRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(
          create: (_) => NavigationBloc(),
        ),
        BlocProvider<PartyBloc>(
          create: (_) => PartyBloc(repository: partyRepository)..add(const FetchPartyRoomsEvent()),
        ),
        BlocProvider<BlockMeBloc>(
          create: (_) => BlockMeBloc(),
        ),
        BlocProvider<MomentsBloc>(
          create: (_) => MomentsBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Royal Chat Live',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
