import 'package:flutter/material.dart';
import 'package:memora/features/village/screens/village_screen.dart'; // Adjust import path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Wait for 3 seconds to simulate loading
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Navigate to the VillageScreen and remove the splash screen from the stack
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VillageScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Your splash screen UI. Can be a simple logo or a Lottie animation.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Example: Using a Lottie file for the "floating island" feel
            // Lottie.asset('assets/animations/island_reveal.json'),
            Text(
              'Memora 🌱',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
