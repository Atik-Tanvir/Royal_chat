import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://wyjkmythhskebenxxblb.supabase.co';
  static const String anonKey = 'sb_publishable_U9J5Jq1Frw94Q73Uei9t5A_KtDdUf3X';

  /// Initializes Supabase client with project URL and Anon key
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  /// Global accessor to the initialized Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}
