import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homescreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027), // Deep Dark Blue
              Color(0xFF203A43),
              Color(0xFF2C5364), // Teal-ish Grey
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo with Glow
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AvatarGlow(
                      startDelay: const Duration(milliseconds: 1000),
                      glowColor: Colors.tealAccent,
                      glowShape: BoxShape.circle,
                      animate: true,
                      curve: Curves.easeOutQuad,
                      child: Container(
                        padding: const EdgeInsets.all(8), // Border width
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ]),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 70,
                          // If Image.asset('assets/abm.png') is transparent, this looks great.
                          // If not, we can wrap in ClipOval or just use the image directly.
                          backgroundImage: const AssetImage('assets/abm.png'),
                          onBackgroundImageError: (_, __) => const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.white,
                          ),
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Animated Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'A B M',
                          style: GoogleFonts.outfit(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              color: Colors.white,
                              height: 1.2),
                        ),
                        Text(
                          'Empowering Students',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    '© ${DateTime.now().year} ABM App',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
