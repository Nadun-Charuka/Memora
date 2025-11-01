import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/auth/screens/splash_screen.dart';
import 'package:memora/fetures/notifications/service/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Colombo'));
  await MemoraNotificationService.init();
  await MemoraNotificationService.scheduleDailyNotifications();

  // // 🧪 TEST: Send immediate notification
  // await MemoraNotificationService.sendTestNotification();

  // // 🧪 TEST: Check pending notifications
  // final pending = await MemoraNotificationService.getPendingNotifications();
  // debugPrint("📊 Pending notifications: ${pending.length}");
  // for (var notif in pending) {
  //   debugPrint("   ID: ${notif.id}, Title: ${notif.title}");
  // }

  runApp(
    const ProviderScope(
      child: MemoraApp(),
    ),
  );
}

class MemoraApp extends StatelessWidget {
  const MemoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9B85C0),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
