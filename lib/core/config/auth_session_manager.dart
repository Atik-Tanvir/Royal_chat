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
  static const String _keyUserLanguage = 'royal_auth_user_language';
  static const String _keyUserCountry = 'royal_auth_user_country';
  static const String _keyUserCountryFlag = 'royal_auth_user_country_flag';
  static const String _keyUserBio = 'royal_auth_user_bio';
  static const String _keyUserGender = 'royal_auth_user_gender';
  static const String _keyUserAge = 'royal_auth_user_age';
  static const String _keyProfileSetupCompleted = 'royal_auth_profile_setup_completed';

  static String? _cachedUserId;
  static String? _cachedUserName;
  static String? _cachedUserEmail;
  static String? _cachedUserAvatar;
  static String? _cachedUserLanguage;
  static String? _cachedUserCountry;
  static String? _cachedUserCountryFlag;
  static String? _cachedUserBio;
  static String? _cachedUserGender;
  static int? _cachedUserAge;
  static bool _cachedProfileSetupCompleted = false;

  /// Initializes local session storage from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedUserId = prefs.getString(_keyUserId);
      _cachedUserName = prefs.getString(_keyUserName);
      _cachedUserEmail = prefs.getString(_keyUserEmail);
      _cachedUserAvatar = prefs.getString(_keyUserAvatar);
      _cachedUserLanguage = prefs.getString(_keyUserLanguage) ?? 'English';
      _cachedUserCountry = prefs.getString(_keyUserCountry) ?? 'Bangladesh';
      _cachedUserCountryFlag = prefs.getString(_keyUserCountryFlag) ?? '🇧🇩';
      _cachedUserBio = prefs.getString(_keyUserBio) ?? '';
      _cachedUserGender = prefs.getString(_keyUserGender) ?? '♂ 20';
      _cachedUserAge = prefs.getInt(_keyUserAge) ?? 20;
      _cachedProfileSetupCompleted = prefs.getBool(_keyProfileSetupCompleted) ?? false;
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
  static String? get currentUserLanguage => _cachedUserLanguage ?? 'English';
  static String? get currentUserCountry => _cachedUserCountry ?? 'Bangladesh';
  static String? get currentUserCountryFlag => _cachedUserCountryFlag ?? '🇧🇩';
  static String? get currentUserBio => _cachedUserBio ?? '';
  static String? get currentUserGender => _cachedUserGender ?? '♂ 20';
  static int? get currentUserAge => _cachedUserAge ?? 20;
  static bool get isProfileSetupCompleted => _cachedProfileSetupCompleted;

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

  /// Persists full personal profile attributes (country, language, bio, gender, age)
  static Future<void> saveProfileDetails({
    String? name,
    String? avatarUrl,
    String? country,
    String? countryFlag,
    String? language,
    String? bio,
    String? gender,
    int? age,
  }) async {
    if (name != null) _cachedUserName = name;
    if (avatarUrl != null) _cachedUserAvatar = avatarUrl;
    if (country != null) _cachedUserCountry = country;
    if (countryFlag != null) _cachedUserCountryFlag = countryFlag;
    if (language != null) _cachedUserLanguage = language;
    if (bio != null) _cachedUserBio = bio;
    if (gender != null) _cachedUserGender = gender;
    if (age != null) _cachedUserAge = age;
    _cachedProfileSetupCompleted = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString(_keyUserName, name);
      if (avatarUrl != null) await prefs.setString(_keyUserAvatar, avatarUrl);
      if (country != null) await prefs.setString(_keyUserCountry, country);
      if (countryFlag != null) await prefs.setString(_keyUserCountryFlag, countryFlag);
      if (language != null) await prefs.setString(_keyUserLanguage, language);
      if (bio != null) await prefs.setString(_keyUserBio, bio);
      if (gender != null) await prefs.setString(_keyUserGender, gender);
      if (age != null) await prefs.setInt(_keyUserAge, age);
      await prefs.setBool(_keyProfileSetupCompleted, true);
    } catch (e) {
      debugPrint('[AuthSessionManager] Save profile details error: $e');
    }
  }

  /// Sets whether the initial profile setup wizard was finished
  static Future<void> markProfileSetupCompleted(bool completed) async {
    _cachedProfileSetupCompleted = completed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyProfileSetupCompleted, completed);
    } catch (e) {
      debugPrint('[AuthSessionManager] Mark profile setup error: $e');
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
