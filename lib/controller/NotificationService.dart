import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_app/controller/HomeController.dart';

class AwesomeNotificationService {
  Future<void> init() async {
    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/res_app_icon',
        [
          NotificationChannel(
            channelKey: 'media_channel',
            channelName: 'Media playback',
            channelDescription: 'Notification channel for media playback',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: false,
            soundSource: 'resource://raw/res_notification',
            importance: NotificationImportance.High,
            channelShowBadge: true,
            defaultRingtoneType: DefaultRingtoneType.Notification,
          )
        ],
      );
      log('Awesome Notifications initialized successfully.');
      await requestNotificationPermission();
      await AwesomeNotifications().requestPermissionToSendNotifications();
      initializeNotificationListeners();
    } catch (e) {
      log('Error initializing Awesome Notifications: $e');
    }
  }

  void initializeNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('Received action: ${receivedAction.toMap()}');

    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      log('Silent action received: "${receivedAction.buttonKeyInput}"');
    } else {
      String action = receivedAction.buttonKeyPressed;
      log('Button pressed: $action');

      if (action == 'play') {
        Get.find<HomeController>().resumeAudio();
      } else if (action == 'pause') {
        Get.find<HomeController>().pauseAudio();
      } else {
        log('Unknown action received: $action');
      }
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showNotification(
      String title, String body, bool isPlaying) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'media_channel',
          title: "RadioLuisteren.fm",
          body: title,
          notificationLayout: NotificationLayout.BigPicture,
          icon: 'resource://drawable/ic_notification',
          payload: {'action': isPlaying ? 'pause' : 'play'},
        ),
        actionButtons: [
          NotificationActionButton(
            key: isPlaying ? 'pause' : 'play',
            label: isPlaying ? 'Pause' : 'Play',
            showInCompactView: true,
            color: isPlaying ? Colors.red : Colors.green,
            actionType: ActionType.Default,
          ),
        ],
      );
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  Future<void> cancelNotification() async {
    await AwesomeNotifications().cancelAll();
  }
}
