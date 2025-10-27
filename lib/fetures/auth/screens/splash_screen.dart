import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'login_screen.dart';
import 'pairing_screen.dart';
import 'home_screen.dart';
import 'dart:math' as math;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _shimmerAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotationController,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 4000));

    if (!mounted) return;

    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    Widget nextScreen;

    if (user == null) {
      nextScreen = const LoginScreen();
    } else {
      final hasCouple = await authService.hasVillage();
      nextScreen = hasCouple ? const HomeScreen() : const PairingScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9B85C0), // Purple
              Color(0xFFB8A4D3), // Light purple
              Color(0xFFE8B4D9), // Pink
              Color(0xFFF5D7E3), // Light pink
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated rotating gradient circles
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF06D6A0).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150,
                      left: -150,
                      child: Transform.rotate(
                        angle: -_rotationAnimation.value,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFE8B4D9).withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Floating flower petals
            ...List.generate(15, (index) {
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final progress =
                      (_particleController.value + (index * 0.1)) % 1.0;
                  final xOffset = math.sin(progress * 2 * math.pi + index) * 50;

                  return Positioned(
                    top: size.height * progress,
                    left: (index * size.width / 15) + xOffset,
                    child: Opacity(
                      opacity: (math.sin(progress * math.pi) * 0.6).clamp(
                        0.0,
                        0.6,
                      ),
                      child: Transform.rotate(
                        angle: progress * 4 * math.pi,
                        child: Icon(
                          [
                            Icons.local_florist,
                            Icons.eco,
                            Icons.favorite,
                            Icons.spa,
                          ][index % 4],
                          size: 20 + (index % 3) * 8.0,
                          color: [
                            const Color(0xFFE8B4D9),
                            const Color(0xFF9B85C0),
                            const Color(0xFF06D6A0),
                            const Color(0xFFF5D7E3),
                          ][index % 4],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Glowing particles
            ...List.generate(25, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1500 + (index * 80)),
                builder: (context, value, child) {
                  return Positioned(
                    top: (index * 60.0) % size.height,
                    left: (index * 50.0) % size.width,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        final shimmerValue =
                            (_shimmerController.value + (index * 0.05)) % 1.0;
                        return Opacity(
                          opacity: (0.15 + (shimmerValue * 0.4)) * value,
                          child: Container(
                            width: 3 + (index % 4),
                            height: 3 + (index % 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha: 0.6 * shimmerValue,
                                  ),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Lottie Animation with pulsing glow
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9B85C0).withValues(
                                    alpha: 0.3 * _pulseAnimation.value,
                                  ),
                                  blurRadius: 60 * _pulseAnimation.value,
                                  spreadRadius: 20 * _pulseAnimation.value,
                                ),
                                BoxShadow(
                                  color: const Color(0xFFE8B4D9).withValues(
                                    alpha: 0.2 * _pulseAnimation.value,
                                  ),
                                  blurRadius: 80 * _pulseAnimation.value,
                                  spreadRadius: 30 * _pulseAnimation.value,
                                ),
                              ],
                            ),
                            child: Lottie.asset(
                              "assets/lottie/Flowers.json",
                              fit: BoxFit.contain,
                              animate: true,
                              repeat: true,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF9B85C0,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 40,
                                        spreadRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                        Icons.park_outlined,
                                        size: 100,
                                        color: Colors.white,
                                      ),
                                      Positioned(
                                        bottom: 30,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'M',
                                            style: TextStyle(
                                              color: Color(0xFF9B85C0),
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    // App Name with advanced gradient and slide
                    SlideTransition(
                      position: _slideAnimation,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color.lerp(
                                    const Color(0xFFE8B4D9),
                                    Colors.white,
                                    _shimmerController.value,
                                  )!,
                                  const Color(0xFF06D6A0),
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.3, 0.6, 1.0],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Memora',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tagline with glassmorphic effect and shimmer
                    SlideTransition(
                      position: _slideAnimation,
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _shimmerAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.15),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🌱',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Watch your relationship grow',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Subtle loading text
                    SlideTransition(
                      position: _slideAnimation,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.5 + (_shimmerController.value * 0.3),
                            child: Text(
                              'Loading your love story...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
