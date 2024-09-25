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
        'resource://drawable/ic_launcher',
        [
          NotificationChannel(
            channelKey: 'media_channel',
            channelName: 'Media playback',
            channelDescription: 'Notification channel for media playback',
            defaultColor: Colors.white,
            ledColor: Colors.white,
            playSound: false,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            defaultRingtoneType: DefaultRingtoneType.Notification,
            locked: true,
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

  Future<void> showOrUpdateNotification(String subtitle, bool isPlaying) async {
    try {
      List<NotificationActionButton> actionButtons = [
        NotificationActionButton(
          key: 'close',
          icon: 'resource://drawable/ic_close',
          label: 'Close',
          showInCompactView: true,
          autoDismissible: false,
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: 'previous',
          icon: 'resource://drawable/ic_previous',
          label: 'Previous',
          showInCompactView: true,
          autoDismissible: false,
          actionType: ActionType.KeepOnTop,
        ),
        if (isPlaying)
          NotificationActionButton(
            key: 'pause',
            icon: 'resource://drawable/ic_pause',
            label: 'Pause',
            showInCompactView: true,
            autoDismissible: false,
            actionType: ActionType.KeepOnTop,
          )
        else
          NotificationActionButton(
            key: 'play',
            icon: 'resource://drawable/ic_play',
            label: 'Play',
            showInCompactView: true,
            autoDismissible: false,
            actionType: ActionType.KeepOnTop,
          ),
        NotificationActionButton(
          key: 'next',
          icon: 'resource://drawable/ic_next',
          label: 'Next',
          showInCompactView: true,
          autoDismissible: false,
          actionType: ActionType.KeepOnTop,
        ),
      ];

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,  // Ensure the same ID is used for updates
          channelKey: 'media_channel',
          title: 'radioluisteren.fm',
          body: subtitle,
          notificationLayout: NotificationLayout.MediaPlayer,
          icon: 'resource://drawable/ic_launcher',
          color: Colors.black,
          backgroundColor: Color(0xFFFFFFFF),
          payload: {'action': isPlaying ? 'pause' : 'play'},
          locked: true,
          autoDismissible: false,
        ),
        actionButtons: actionButtons,
      );

      log('Notification shown or updated successfully.');
    } catch (e, stacktrace) {
      log('Error showing or updating notification: $e');
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

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    log('Received action: ${receivedAction.toMap()}');
    final homeController = Get.find<HomeController>();

    switch (receivedAction.buttonKeyPressed) {
      case 'play':
        log('Play button pressed');
        homeController.resumeAudio();
        // Update notification to show the pause button without canceling it
        AwesomeNotificationService().showOrUpdateNotification('Now playing', true);
        break;
      case 'pause':
        log('Pause button pressed');
        homeController.pauseAudio();
        // Update notification to show the play button without canceling it
        AwesomeNotificationService().showOrUpdateNotification('Paused', false);
        break;
      case 'previous':
        log('Previous button pressed');
        homeController.previousStation();
        // Update notification to reflect the previous station without canceling it
        AwesomeNotificationService().showOrUpdateNotification('Previous station', true);
        break;
      case 'next':
        log('Next button pressed');
        homeController.nextStation();
        // Update notification to reflect the next station without canceling it
        AwesomeNotificationService().showOrUpdateNotification('Next station', true);
        break;
      case 'close':
        log('Close button pressed');
        homeController.closeAudio();
        // Optionally cancel the notification only when the close button is pressed
        await AwesomeNotifications().cancel(10);
        break;
      default:
        log('Unknown button pressed: ${receivedAction.buttonKeyPressed}');
    }
  }

}
