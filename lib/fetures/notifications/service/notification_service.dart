import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class MemoraNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int morningNotificationId = 1;
  static const int eveningNotificationId = 2;

  /// Initialize the notification service
  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/launcher_icon");
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: darwinInitializationSettings,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions (Android 13+)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Schedule both morning and evening notifications
  static Future<void> scheduleDailyNotifications() async {
    await scheduleMorningNotification();
    await scheduleEveningNotification();
    debugPrint("✅ Memora daily notifications scheduled");
  }

  /// Schedule 9 AM morning notification
  static Future<void> scheduleMorningNotification() async {
    await _scheduleDailyNotification(
      id: morningNotificationId,
      hour: 9,
      minute: 0,
      title: _getRandomMorningTitle(),
      body: _getRandomMorningMessage(),
    );
  }

  /// Schedule 10 PM evening notification
  static Future<void> scheduleEveningNotification() async {
    await _scheduleDailyNotification(
      id: eveningNotificationId,
      hour: 22,
      minute: 0,
      title: _getRandomEveningTitle(),
      body: _getRandomEveningMessage(),
    );
  }

  /// Core scheduling logic
  static Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint("⏳ Scheduling Memora notification for $scheduled");

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "memora_daily_reminders",
          "Daily Love Reminders",
          channelDescription: 'Gentle reminders to nurture your love tree',
          importance: Importance.high,
          priority: Priority.high,
          icon: "@mipmap/launcher_icon",
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("🔕 All Memora notifications cancelled");
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint("🔕 Notification $id cancelled");
  }

  /// Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Send immediate test notification
  static Future<void> sendTestNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      999,
      "🌳 Memora Test",
      "Your notifications are working perfectly!",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "memora_daily_reminders",
          "Daily Love Reminders",
          importance: Importance.high,
          priority: Priority.high,
          icon: "@mipmap/launcher_icon",
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ============== MORNING MESSAGES ==============

  static final List<String> _morningTitles = [
    "🌱 Good morning!",
    "☀️ Rise and shine!",
    "💭 Morning thoughts?",
    "🌸 A new day begins",
    "✨ Start your day with love",
  ];

  static final List<String> _morningMessages = [
    "Start your day by sharing a moment with your partner",
    "What made you smile this morning?",
    "Share today's first thought together",
    "Plant a memory seed in your love tree",
    "Begin the day with gratitude for each other",
  ];

  static String _getRandomMorningTitle() {
    return _morningTitles[Random().nextInt(_morningTitles.length)];
  }

  static String _getRandomMorningMessage() {
    return _morningMessages[Random().nextInt(_morningMessages.length)];
  }

  // ============== EVENING MESSAGES ==============

  static final List<String> _eveningTitles = [
    "🌙 How was your day?",
    "✨ Before you sleep...",
    "💫 End your day together",
    "🌟 Tonight's moment",
    "🍃 Reflect and share",
  ];

  static final List<String> _eveningMessages = [
    "Add today's memory and watch your love tree grow",
    "Capture one special moment from today",
    "What made today meaningful?",
    "Share tonight's gratitude with your partner",
    "Don't let today's memories fade away",
  ];

  static String _getRandomEveningTitle() {
    return _eveningTitles[Random().nextInt(_eveningTitles.length)];
  }

  static String _getRandomEveningMessage() {
    return _eveningMessages[Random().nextInt(_eveningMessages.length)];
  }
}
