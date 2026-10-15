import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/config/auth_session_manager.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Backend
  await SupabaseConfig.initialize();

  // Initialize Session Manager
  await AuthSessionManager.init();

  // Set system UI overlay style matching dark green gaming party theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF074836),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const GemgalaApp());
}
