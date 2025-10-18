import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/onboarding/screen/splash_screen.dart';
import 'package:memora/fetures/tree/screen/village_screen.dart';
import 'package:memora/firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MemoraApp(),
    ),
  );
}

class MemoraApp extends ConsumerWidget {
  const MemoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Memora - Love Village',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Navigation
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,

      // Or use home with auth logic
      home: const AuthWrapper(),
    );
  }
}

/// Decides which screen to show based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Not logged in - show splash then login
          return const SplashScreen();
        } else {
          // Logged in - check if paired
          return const CoupleCheckWrapper();
        }
      },
      loading: () => const SplashScreen(),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Retry or navigate to login
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Checks if user is paired with a partner
class CoupleCheckWrapper extends ConsumerWidget {
  const CoupleCheckWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return user.when(
      data: (userData) {
        if (userData?.coupleId == null || userData!.coupleId!.isEmpty) {
          // Not paired - show pairing screen
          return const PairingScreen();
        } else {
          // Paired - show village
          return VillageScreen(coupleId: userData.coupleId!);
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading user: $error')),
      ),
    );
  }
}

// Placeholder for PairingScreen (you'll create this)
class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💑',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pair with Your Partner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to pairing screen
                Navigator.pushNamed(context, AppRouter.pairing);
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
