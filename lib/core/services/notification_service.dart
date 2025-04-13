import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Initialize settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'mass_manager_channel',
      'Mass Manager Notifications',
      channelDescription: 'Notifications from Mass Manager app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'mass_manager_scheduled_channel',
      'Mass Manager Scheduled Notifications',
      channelDescription: 'Scheduled notifications from Mass Manager app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //uiLocalNotificationDateInterpretation:
      //UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Schedule daily meal reminder
  Future<void> scheduleDailyMealReminder({
    required String title,
    required String body,
    required int hour,
    required int minute,
    int id = 0,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
  }

  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Schedule breakfast reminder
  Future<void> scheduleBreakfastReminder() async {
    await scheduleDailyMealReminder(
      id: 1,
      title: 'Breakfast Reminder',
      body: 'Don\'t forget to update your breakfast status for today!',
      hour: 8,
      minute: 0,
    );
  }

  // Schedule lunch reminder
  Future<void> scheduleLunchReminder() async {
    await scheduleDailyMealReminder(
      id: 2,
      title: 'Lunch Reminder',
      body: 'Don\'t forget to update your lunch status for today!',
      hour: 13,
      minute: 0,
    );
  }

  // Schedule dinner reminder
  Future<void> scheduleDinnerReminder() async {
    await scheduleDailyMealReminder(
      id: 3,
      title: 'Dinner Reminder',
      body: 'Don\'t forget to update your dinner status for today!',
      hour: 19,
      minute: 0,
    );
  }

  // Schedule all meal reminders
  Future<void> scheduleAllMealReminders() async {
    await scheduleBreakfastReminder();
    await scheduleLunchReminder();
    await scheduleDinnerReminder();
  }
}