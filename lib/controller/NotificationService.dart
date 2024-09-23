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
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            defaultRingtoneType: DefaultRingtoneType.Notification,
          ),
        ],
      );
      log('Awesome Notifications initialized successfully.');
      await requestNotificationPermission();
      initializeNotificationListeners();
    } catch (e, stacktrace) {
      log('Error initializing Awesome Notifications: $e');
      log('Stacktrace: $stacktrace');
    }
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      log('Requesting notification permission...');
      status = await Permission.notification.request();
    }
    log('Notification permission status: $status');
  }

  void initializeNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('Received action: ${receivedAction.toMap()}');
    if (receivedAction.buttonKeyPressed == 'play') {
      log('Play button pressed');
      Get.find<HomeController>().resumeAudio();
    } else if (receivedAction.buttonKeyPressed == 'pause') {
      log('Pause button pressed');
      Get.find<HomeController>().pauseAudio();
    } else {
      log('Unknown button pressed: ${receivedAction.buttonKeyPressed}');
    }
  }

  Future<void> showNotification(String subtitle, bool isPlaying) async {
    try {
      List<NotificationActionButton> actionButtons = [];

      if (isPlaying) {
        actionButtons.add(
          NotificationActionButton(
            key: 'pause',
            icon: 'resource://drawable/ic_pause',
            label: 'Pause',
            showInCompactView: true,
            actionType: ActionType.KeepOnTop,
          ),
        );
      } else {
        actionButtons.add(
          NotificationActionButton(
            key: 'play',
            icon: 'resource://drawable/ic_play',
            label: 'Play',
            showInCompactView: true,
            actionType: ActionType.KeepOnTop,
          ),
        );
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'media_channel',
          title: "radioluisteren.fm",
          body: subtitle,
          notificationLayout: NotificationLayout.MediaPlayer,
          icon: 'resource://drawable/ic_notification',
          largeIcon: 'resource://drawable/ic_large_icon',
          payload: {'action': isPlaying ? 'pause' : 'play'},
          locked: true,
          autoDismissible: false,
        ),
        actionButtons: actionButtons,
      );

      log('Notification shown successfully.');
    } catch (e, stacktrace) {
      log('Error showing notification: $e');
      log('Stacktrace: $stacktrace');
    }
  }

  Future<void> cancelNotification() async {
    try {
      await AwesomeNotifications().cancel(10);
      log('Notification canceled successfully.');
    } catch (e, stacktrace) {
      log('Error canceling notification: $e');
      log('Stacktrace: $stacktrace');
    }
  }
}
