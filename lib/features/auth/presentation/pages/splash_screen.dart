import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../../../navigation/presentation/pages/main_navigation_page.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // 2.2 second splash duration before navigating
    _navTimer = Timer(const Duration(milliseconds: 2200), _handleNavigation);
  }

  void _handleNavigation() {
    if (!mounted) return;
    final bool isAuthenticated = AuthSessionManager.hasActiveSession;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) =>
            isAuthenticated ? const MainNavigationPage() : const LoginPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041510),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Luxury Ambient Radial Glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35 - 150,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.25),
                    const Color(0xFFFFD700).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Logo and Title
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Golden Crest Logo with Halo
                    Container(
                      width: 96,
                      height: 96,
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
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: RoyalBrandLogo(size: 64),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Minimal Luxury Brand Typography
                    Text(
                      'ROYAL CHAT LIVE',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'VOICE & GAMING PARTY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: const Color(0xFF34D399).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Minimal Loading Indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFFD700).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
