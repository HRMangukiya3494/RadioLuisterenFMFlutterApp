import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:radio_app/controller/HomeController.dart'; // Adjust import as per your file structure

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the notification system
  Future<void> init() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Handle the case when a notification is received while the app is in the foreground
        Get.snackbar(title ?? 'Notification', body ?? '');
      },
    );

    // Combined initialization settings for Android and iOS
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize notification plugin with a callback for when a notification is tapped
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'pause') {
          Get.find<HomeController>().pauseAudio();
        } else if (response.payload == 'play') {
          Get.find<HomeController>().resumeAudio();
        } else if (response.payload == 'stop') {
          Get.find<HomeController>().stopAudio();
        }
      },
    );

    // Request notification permission for Android 13+ (API level 33+)
    await requestNotificationPermission();

    // Request notification permission for iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Request notification permission (needed for Android 13+)
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Show a notification with play, pause, and stop actions
  Future<void> showNotification(String title, String body, bool isPlaying) async {
    // Android-specific notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'Media Playback', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      playSound: false,
      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
      actions: [
        AndroidNotificationAction('pause', 'Pause'),
        AndroidNotificationAction('play', 'Play'),
        AndroidNotificationAction('stop', 'Stop'),
      ],
    );

    // iOS-specific notification details
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,   // Show alert
      presentBadge: true,   // Update badge
      presentSound: true,   // Play sound
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails,
    );

    if (isPlaying) {
      // Show notification when playing
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        platformChannelSpecifics,
        payload: 'pause',
      );
    } else {
      // Cancel notification when paused
      await flutterLocalNotificationsPlugin.cancel(0); // Clear the notification when paused
    }
  }

  // Cancel all notifications
  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
