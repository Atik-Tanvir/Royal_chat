import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

/// Manages active authentication session and persistent user identification.
///
/// Ensures every user (Google OAuth or Dynamic Guest) has a real, persistent
/// user ID corresponding to an actual row in the Supabase 'profiles' table.
class AuthSessionManager {
  static const String _keyGuestUserId = 'royal_guest_user_id';
  static String? _cachedGuestId;

  /// Initializes local session storage from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedGuestId = prefs.getString(_keyGuestUserId);
    } catch (e) {
      debugPrint('[AuthSessionManager] Init error: $e');
    }
  }

  /// Returns the active authenticated user ID, or the persistent guest user ID.
  static String? get currentUserId {
    final supabaseUser = SupabaseConfig.client.auth.currentUser;
    if (supabaseUser != null) {
      return supabaseUser.id;
    }
    return _cachedGuestId;
  }

  /// Returns true if a session (authenticated or guest) is active
  static bool get hasActiveSession {
    return SupabaseConfig.client.auth.currentSession != null || (_cachedGuestId != null && _cachedGuestId!.isNotEmpty);
  }

  /// Persists a dynamic guest user ID
  static Future<void> setGuestUserId(String guestId) async {
    _cachedGuestId = guestId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyGuestUserId, guestId);
    } catch (e) {
      debugPrint('[AuthSessionManager] Save guest ID error: $e');
    }
  }

  /// Clears active session (both Supabase Auth and local guest)
  static Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthSessionManager] Supabase signOut error: $e');
    }

    _cachedGuestId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGuestUserId);
    } catch (e) {
      debugPrint('[AuthSessionManager] Remove guest ID error: $e');
    }
  }
}
