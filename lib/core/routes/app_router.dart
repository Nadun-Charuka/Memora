import 'package:flutter/material.dart';
import 'package:memora/fetures/auth/screen/login_screen.dart';
import 'package:memora/fetures/auth/screen/signup_screen.dart';
import 'package:memora/fetures/onboarding/screen/splash_screen.dart';
import 'package:memora/fetures/tree/screen/village_screen.dart';
import 'package:memora/main.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String pairing = '/pairing';
  static const String village = '/village';
  static const String addMemo = '/add-memo';
  static const String memoList = '/memo-list';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      // case welcome:
      //   return MaterialPageRoute(
      //     builder: (_) => const WelcomeScreen(),
      //   );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case pairing:
        return MaterialPageRoute(
          builder: (_) => const PairingScreen(),
        );

      case village:
        final coupleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VillageScreen(coupleId: coupleId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
