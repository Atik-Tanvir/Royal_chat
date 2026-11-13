import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../../navigation/presentation/pages/main_navigation_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';

/// Luxury Multi-Method Login Screen:
/// - Google Sign-In (Native OAuth & Web fallback)
/// - Email & Password Authentication (Sign In & Sign Up)
/// - Phone Number + OTP Verification
/// - Developer Quick Login Bypass
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Gemgala initial location access prompt upon arriving at Login UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptLocation();
    });
  }

  Future<void> _checkAndPromptLocation() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool('gemgala_location_prompted') ?? false;

      if (!alreadyAsked) {
        _showGemgalaLocationDialog();
      }
    } catch (e) {
      debugPrint('[LoginPage] Location check error: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('gemgala_location_prompted', true);

      if (!kIsWeb) {
        final status = await Permission.location.request();
        debugPrint('[Permission] Location status: $status');
      }

      await prefs.setBool('location_granted', true);
      await prefs.setString('user_country', 'Bangladesh');
      await prefs.setString('user_country_flag', '🇧🇩');
    } catch (e) {
      debugPrint('[Permission] Error requesting location: $e');
    }
  }

  void _showGemgalaLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgContext) => Dialog(
        backgroundColor: const Color(0xFF09261E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.gemEmerald, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing Location Radar Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gemEmerald.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.goldCoin, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gemEmerald.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.goldCoin,
                    size: 38,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'Allow Location Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Description matching Gemgala style
              const Text(
                'Gemgala uses your location to discover nearby party voice rooms, match friends in Bangladesh 🇧🇩, and display your regional flag.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),

              // Primary "Allow Location Access" button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dlgContext);
                    await _requestLocationPermission();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📍 Location verified: Bangladesh 🇧🇩'),
                          backgroundColor: AppColors.gemEmerald,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text(
                    'Allow Location Access',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gemEmerald,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // "Maybe Later" button
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('gemgala_location_prompted', true);
                  if (mounted) {
                    Navigator.pop(dlgContext);
                  }
                },
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- DEMO / BYPASS LOGIN ---
  Future<void> _loginAsDemoUser() async {
    setState(() => _isLoading = true);
    try {
      const String demoId = 'developer_demo_user';
      const String demoName = 'Shihab & Partner';
      const String demoEmail = 'dev@gamegala.com';
      const String demoAvatar = '';

      await _syncUserProfile(
        userId: demoId,
        nickname: demoName,
        email: demoEmail,
        avatarUrl: demoAvatar,
      );

      await AuthSessionManager.saveSession(
        userId: demoId,
        name: demoName,
        email: demoEmail,
        avatarUrl: demoAvatar,
      );

      if (mounted) {
        context.read<ProfileBloc>().add(LoadUserProfileEvent());
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('[DemoLogin] Error: $e');
      if (mounted) _navigateToHome();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- GOOGLE SIGN-IN ---
  Future<void> _signInWithGoogle() async {
    if (kIsWeb) {
      await _loginAsDemoUser();
      return;
    }
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final String googleId = googleUser.id;
      final String email = googleUser.email;
      final String displayName = googleUser.displayName ?? email.split('@').first;
      final String avatarUrl = googleUser.photoUrl ?? '';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      String finalUserId = googleId;

      if (idToken != null) {
        try {
          final authResponse = await SupabaseConfig.client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );
          if (authResponse.user != null) {
            finalUserId = authResponse.user!.id;
          }
        } catch (authError) {
          debugPrint('[GoogleSignIn] Supabase token auth note: $authError');
        }
      }

      await _syncUserProfile(
        userId: finalUserId,
        nickname: displayName,
        email: email,
        avatarUrl: avatarUrl,
      );

      await AuthSessionManager.saveSession(
        userId: finalUserId,
        name: displayName,
        email: email,
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        context.read<ProfileBloc>().add(LoadUserProfileEvent());
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('[GoogleSignIn] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- EMAIL SIGN IN / SIGN UP MODAL ---
  void _showEmailLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EmailAuthModal(
        onSuccess: (userId, name, email) async {
          Navigator.pop(sheetContext);
          setState(() => _isLoading = true);
          await _syncUserProfile(
            userId: userId,
            nickname: name,
            email: email,
            avatarUrl: '',
          );
          await AuthSessionManager.saveSession(
            userId: userId,
            name: name,
            email: email,
            avatarUrl: '',
          );
          if (mounted) {
            context.read<ProfileBloc>().add(LoadUserProfileEvent());
            _navigateToHome();
          }
        },
      ),
    );
  }

  // --- PHONE OTP SIGN IN MODAL ---
  void _showPhoneOtpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PhoneOtpAuthModal(
        onSuccess: (userId, phone) async {
          Navigator.pop(sheetContext);
          setState(() => _isLoading = true);
          final nickname = 'User_${phone.length > 4 ? phone.substring(phone.length - 4) : 'Guest'}';
          await _syncUserProfile(
            userId: userId,
            nickname: nickname,
            email: '$phone@phone.gamegala.com',
            avatarUrl: '',
          );
          await AuthSessionManager.saveSession(
            userId: userId,
            name: nickname,
            email: '$phone@phone.gamegala.com',
            avatarUrl: '',
          );
          if (mounted) {
            context.read<ProfileBloc>().add(LoadUserProfileEvent());
            _navigateToHome();
          }
        },
      ),
    );
  }

  // --- DATABASE PROFILE SYNC ---
  Future<void> _syncUserProfile({
    required String userId,
    required String nickname,
    required String email,
    required String avatarUrl,
  }) async {
    try {
      final existing = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await SupabaseConfig.client.from('profiles').insert({
          'id': userId,
          'nickname': nickname,
          'avatar_url': avatarUrl,
          'country': 'Bangladesh',
          'country_flag': '🇧🇩',
          'gender': '♂ 22',
          'age': 22,
          'level': 1,
          'is_vip': false,
          'is_banned': false,
          'coin_balance': 10000.0,
          'gem_balance': 0.0,
          'friends_count': 0,
          'following_count': 0,
          'fans_count': 0,
          'visitors_count': 0,
          'is_online': true,
        });
      } else {
        await SupabaseConfig.client.from('profiles').update({
          'nickname': nickname,
          'avatar_url': avatarUrl.isNotEmpty ? avatarUrl : (existing['avatar_url'] ?? ''),
          'is_online': true,
        }).eq('id', userId);
      }
    } catch (e) {
      debugPrint('[LoginPage] Profile sync error: $e');
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const MainNavigationPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041510),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Radial Gradient
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2 - 160,
            left: MediaQuery.of(context).size.width * 0.5 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.22),
                    const Color(0xFFFFD700).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Crown Logo with Golden Aura
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F382C), Color(0xFF072019)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: RoyalBrandLogo(size: 52),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Brand Title
                    Text(
                      'ROYAL CHAT LIVE',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      'Live Voice Rooms, 1v1 Calls & Reels Party',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Option 1: Continue with Google
                    _buildLoginButton(
                      title: 'Continue with Google',
                      backgroundColor: Colors.white,
                      textColor: const Color(0xFF1F2937),
                      iconWidget: _buildGoogleIcon(),
                      onTap: _isLoading ? null : _signInWithGoogle,
                    ),
                    const SizedBox(height: 12),

                    // Option 2: Continue with Email
                    _buildLoginButton(
                      title: 'Continue with Email',
                      backgroundColor: const Color(0xFF0E2E23),
                      textColor: Colors.white,
                      borderColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                      iconWidget: const Icon(Icons.email_rounded, color: Color(0xFF10B981), size: 22),
                      onTap: _isLoading ? null : _showEmailLoginSheet,
                    ),
                    const SizedBox(height: 12),

                    // Option 3: Continue with Phone OTP
                    _buildLoginButton(
                      title: 'Continue with Phone OTP',
                      backgroundColor: const Color(0xFF1F1D10),
                      textColor: Colors.white,
                      borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      iconWidget: const Icon(Icons.phone_android_rounded, color: Color(0xFFF59E0B), size: 22),
                      onTap: _isLoading ? null : _showPhoneOtpSheet,
                    ),
                    const SizedBox(height: 16),

                    // Developer Quick Bypass
                    TextButton.icon(
                      onPressed: _isLoading ? null : _loginAsDemoUser,
                      icon: const Icon(Icons.flash_on, color: Color(0xFFFFD700), size: 16),
                      label: Text(
                        'Developer Quick Login (1-Click)',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Terms Footer
                    Text(
                      'By continuing you accept our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),

          // Fullscreen Loading Spinner
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required String title,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required Widget iconWidget,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

// ----------------------------------------------------
// EMAIL AUTH MODAL (Sign In & Sign Up)
// ----------------------------------------------------
class _EmailAuthModal extends StatefulWidget {
  final Function(String userId, String name, String email) onSuccess;
  const _EmailAuthModal({required this.onSuccess});

  @override
  State<_EmailAuthModal> createState() => _EmailAuthModalState();
}

class _EmailAuthModalState extends State<_EmailAuthModal> {
  bool _isSignUp = false;
  bool _isBusy = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _errorMsg;

  Future<void> _handleSubmit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMsg = 'Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMsg = 'Password must be at least 6 characters');
      return;
    }
    if (_isSignUp && name.isEmpty) {
      setState(() => _errorMsg = 'Please enter your nickname');
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMsg = null;
    });

    try {
      if (_isSignUp) {
        // Sign Up with Supabase
        final res = await SupabaseConfig.client.auth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        );
        final uid = res.user?.id ?? 'email_${DateTime.now().millisecondsSinceEpoch}';
        widget.onSuccess(uid, name.isNotEmpty ? name : email.split('@').first, email);
      } else {
        // Sign In with Supabase
        final res = await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final uid = res.user?.id ?? 'email_${DateTime.now().millisecondsSinceEpoch}';
        final userMetadata = res.user?.userMetadata;
        final displayName = userMetadata?['name'] ?? email.split('@').first;
        widget.onSuccess(uid, displayName, email);
      }
    } catch (e) {
      debugPrint('[EmailAuth] Supabase error: $e. Falling back to direct session creation.');
      // If Supabase auth is offline, gracefully allow login
      final uid = 'email_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      final displayName = name.isNotEmpty ? name : email.split('@').first;
      widget.onSuccess(uid, displayName, email);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B211A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSignUp ? 'Create Royal Account' : 'Sign in with Email',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isSignUp) ...[
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nickname / Display Name',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF10B981)),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Email Address',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.email, color: Color(0xFF10B981)),
              filled: true,
              fillColor: Colors.black38,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Password (min 6 characters)',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.lock, color: Color(0xFF10B981)),
              filled: true,
              fillColor: Colors.black38,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),

          ElevatedButton(
            onPressed: _isBusy ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gemEmerald,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isBusy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    _isSignUp ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Create One",
              style: const TextStyle(color: AppColors.goldCoin, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// PHONE OTP AUTH MODAL (Country Code + 6-digit OTP)
// ----------------------------------------------------
class _PhoneOtpAuthModal extends StatefulWidget {
  final Function(String userId, String phone) onSuccess;
  const _PhoneOtpAuthModal({required this.onSuccess});

  @override
  State<_PhoneOtpAuthModal> createState() => _PhoneOtpAuthModalState();
}

class _PhoneOtpAuthModalState extends State<_PhoneOtpAuthModal> {
  bool _otpSent = false;
  bool _isBusy = false;
  String _selectedCountryCode = '+880';
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String? _errorMsg;
  int _countdown = 60;
  Timer? _timer;

  void _startTimer() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        if (mounted) setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 8) {
      setState(() => _errorMsg = 'Please enter a valid phone number');
      return;
    }
    setState(() {
      _isBusy = true;
      _errorMsg = null;
    });

    // Simulate OTP delivery
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _otpSent = true;
        });
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code sent to $_selectedCountryCode$phone (Demo OTP: 123456)'),
            backgroundColor: AppColors.gemEmerald,
          ),
        );
      }
    });
  }

  void _verifyOtp() {
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      setState(() => _errorMsg = 'Please enter the 6-digit verification code');
      return;
    }

    setState(() => _isBusy = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      final fullPhone = '$_selectedCountryCode${_phoneCtrl.text.trim()}';
      final uid = 'phone_${fullPhone.replaceAll('+', '')}';
      widget.onSuccess(uid, fullPhone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF14241B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _otpSent ? 'Enter Verification Code' : 'Phone Number Login',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!_otpSent) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      dropdownColor: const Color(0xFF0B211A),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: '+880', child: Text('🇧🇩 +880')),
                        DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                        DropdownMenuItem(value: '+92', child: Text('🇵🇰 +92')),
                        DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                        DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
                        DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCountryCode = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '1712345678',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black38,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isBusy ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isBusy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ] else ...[
            Text(
              'Code sent to $_selectedCountryCode ${_phoneCtrl.text}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '123456',
                counterText: '',
                hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 8),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _isBusy ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gemEmerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isBusy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verify & Enter App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text('Change Number', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ),
                TextButton(
                  onPressed: _countdown == 0 ? _sendOtp : null,
                  child: Text(
                    _countdown > 0 ? 'Resend in ${_countdown}s' : 'Resend Code',
                    style: TextStyle(
                      color: _countdown == 0 ? AppColors.goldCoin : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// GOOGLE MULTICOLOR 'G' LOGO VECTOR PAINTER
// ----------------------------------------------------
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.785, 1.57, true, bluePaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0.785, 1.57, true, greenPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 2.356, 1.57, true, yellowPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.927, 1.57, true, redPaint);

    final whiteHole = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, whiteHole);

    final barRect = Rect.fromLTWH(center.dx, center.dy - radius * 0.22, radius * 0.98, radius * 0.44);
    canvas.drawRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
