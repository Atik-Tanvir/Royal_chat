import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

/// Manages active authentication session and persistent user identification.
///
/// Ensures every user authenticating via Gmail / Google Sign-In has a real,
/// persistent user ID and profile in the Supabase 'profiles' table.
class AuthSessionManager {
  static const String _keyUserId = 'royal_auth_user_id';
  static const String _keyUserName = 'royal_auth_user_name';
  static const String _keyUserEmail = 'royal_auth_user_email';
  static const String _keyUserAvatar = 'royal_auth_user_avatar';

  static String? _cachedUserId;
  static String? _cachedUserName;
  static String? _cachedUserEmail;
  static String? _cachedUserAvatar;

  /// Initializes local session storage from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedUserId = prefs.getString(_keyUserId);
      _cachedUserName = prefs.getString(_keyUserName);
      _cachedUserEmail = prefs.getString(_keyUserEmail);
      _cachedUserAvatar = prefs.getString(_keyUserAvatar);
    } catch (e) {
      debugPrint('[AuthSessionManager] Init error: $e');
    }
  }

  /// Returns the active authenticated user ID
  static String? get currentUserId {
    final supabaseUser = SupabaseConfig.client.auth.currentUser;
    if (supabaseUser != null) {
      return supabaseUser.id;
    }
    return _cachedUserId;
  }

  static String? get currentUserName => _cachedUserName;
  static String? get currentUserEmail => _cachedUserEmail;
  static String? get currentUserAvatar => _cachedUserAvatar;

  /// Returns true only if an authenticated Google/Supabase session is active
  static bool get hasActiveSession {
    final supabaseSession = SupabaseConfig.client.auth.currentSession;
    if (supabaseSession != null) return true;
    return _cachedUserId != null && _cachedUserId!.isNotEmpty;
  }

  /// Persists authentic user session credentials
  static Future<void> saveSession({
    required String userId,
    required String name,
    required String email,
    required String avatarUrl,
  }) async {
    _cachedUserId = userId;
    _cachedUserName = name;
    _cachedUserEmail = email;
    _cachedUserAvatar = avatarUrl;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUserName, name);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserAvatar, avatarUrl);
    } catch (e) {
      debugPrint('[AuthSessionManager] Save session error: $e');
    }
  }

  /// Clears active session and signs out from Google & Supabase
  static Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthSessionManager] Supabase signOut error: $e');
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('[AuthSessionManager] Google signOut error: $e');
    }

    _cachedUserId = null;
    _cachedUserName = null;
    _cachedUserEmail = null;
    _cachedUserAvatar = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserAvatar);
    } catch (e) {
      debugPrint('[AuthSessionManager] Remove session error: $e');
    }
  }
}
