import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://bzzzbogcrhfjahtrnazy.supabase.co';
  static const String anonKey = 'sb_publishable_PaIpRE7SMQ9ju3Pfxw7B5A_p287ahmd';

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
