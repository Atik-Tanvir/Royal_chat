import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../../navigation/presentation/pages/main_navigation_page.dart';

/// Luxury Login Screen for Royal Chat Live.
/// 
/// Provides dedicated Gmail (Google Sign-In) authentication via Supabase OAuth.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late StreamSubscription<AuthState> _authSubscription;
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

    // Listen for auth state changes (e.g. redirected back from Google OAuth)
    _authSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null && mounted) {
        // Sync or register user in Supabase 'profiles' table
        await _syncProfile(session.user);
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _syncProfile(User user) async {
    try {
      final name = user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String? ??
          user.email?.split('@').first ??
          'RoyalUser';
      final avatar = user.userMetadata?['avatar_url'] as String? ?? '';

      await SupabaseConfig.client.from('profiles').upsert({
        'id': user.id,
        'nickname': name,
        'avatar_url': avatar,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[LoginPage] Profile sync error: $e');
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainNavigationPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final success = await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'royalchat://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!success && mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in note: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031A14),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gemEmerald.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldCoin.withValues(alpha: 0.12),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // 3D Textless Emblem Logo
                    const RoyalBrandLogo(size: 110),
                    const SizedBox(height: 20),

                    // App Brand Name
                    Text(
                      'ROYAL CHAT LIVE',
                      style: AppTextStyles.headerLarge.copyWith(
                        color: AppColors.goldCoin,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Tagline
                    Text(
                      'Luxury Voice Chat & Party Gaming Arena',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 2),

                    // Feature highlights pill box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(Icons.mic, 'HD Real-Time WebRTC Voice Chat', AppColors.gemEmerald),
                          const SizedBox(height: 10),
                          _buildFeatureRow(Icons.card_giftcard, '3D Luxury Imperial Gifts & Banners', AppColors.goldCoin),
                          const SizedBox(height: 10),
                          _buildFeatureRow(Icons.casino, 'Lucky Race Mini-Games & Live Earnings', AppColors.accentOrange),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Primary Google / Gmail Sign-In Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Official Google 4-color 'G' icon representation
                                  _buildGoogleIcon(),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Gmail / Google',
                                    style: TextStyle(
                                      color: Color(0xFF1F1F1F),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Guest / Demo exploration mode
                    TextButton(
                      onPressed: _navigateToHome,
                      child: Text(
                        'Continue as Guest',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Terms note
                    Text(
                      'By continuing, you agree to our Terms of Service & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.2),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

/// Precise vector painter for Google's official 4-color 'G' icon.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paint = Paint()..isAntiAlias = true;

    // Blue segment (Right bar & top right)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(w * 0.95, h * 0.5)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.5, h * 0.72)
      ..lineTo(w * 0.78, h * 0.72)
      ..cubicTo(w * 0.73, h * 0.84, w * 0.63, h * 0.9, w * 0.5, h * 0.9)
      ..lineTo(w * 0.5, h)
      ..cubicTo(w * 0.78, h, w, h * 0.78, w, h * 0.5)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Green segment (Bottom)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(w * 0.5, h)
      ..cubicTo(w * 0.23, h, 0, h * 0.77, 0, h * 0.5)
      ..lineTo(w * 0.18, h * 0.5)
      ..cubicTo(w * 0.18, h * 0.68, w * 0.32, h * 0.82, w * 0.5, h * 0.82)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Yellow segment (Bottom left)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(0, h * 0.36, w * 0.05, h * 0.23, w * 0.14, h * 0.14)
      ..lineTo(w * 0.27, h * 0.27)
      ..cubicTo(w * 0.21, h * 0.33, w * 0.18, h * 0.41, w * 0.18, h * 0.5)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Red segment (Top)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(w * 0.14, h * 0.14)
      ..cubicTo(w * 0.23, h * 0.05, w * 0.36, 0, w * 0.5, 0)
      ..cubicTo(w * 0.73, 0, w * 0.86, h * 0.1, w * 0.92, h * 0.22)
      ..lineTo(w * 0.76, h * 0.35)
      ..cubicTo(w * 0.71, h * 0.25, w * 0.61, h * 0.18, w * 0.5, h * 0.18)
      ..cubicTo(w * 0.39, h * 0.18, w * 0.3, h * 0.25, w * 0.25, h * 0.33)
      ..close();
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
