import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:radio_app/controller/NotificationService.dart';
import 'package:xml/xml.dart' as xml;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var stations = <Map<String, String>>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  var currentStreamUrl = ''.obs;
  var currentStation = <String, String>{}.obs;
  var currentIndex = 0.obs;
  var isPlaying = false.obs;
  var firstPlay = false.obs;
  var isMuted = false.obs;
  var playbackPosition = 0.0.obs;
  var duration = 0.0.obs;
  var volume = 1.0.obs;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _connectivitySubscription;

  @override
  void onInit() {
    fetchStations();
    _checkInternetConnection();
    AwesomeNotificationService().init();
    super.onInit();
  }

  void _checkInternetConnection() {
    _connectivitySubscription = InternetConnectionChecker().onStatusChange.listen((status) async {
      switch (status) {
        case InternetConnectionStatus.connected:
          log('Connected to the internet');
          if (currentStreamUrl.value.isNotEmpty && !isPlaying.value) {
            playPause(currentStreamUrl.value, currentIndex.value);
          }
          break;
        case InternetConnectionStatus.disconnected:
          log('No internet connection');
          if (isPlaying.value) {
            audioPlayer.pause();
            isPlaying(false);
            AwesomeNotificationService().cancelNotification();
          }
          break;
      }
    });
  }

  void fetchStations() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('https://www.radioluisteren.fm/streams.rss'));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        stations.value = items.map((item) {
          return {
            'title': item.findElements('title').first.text,
            'link': item.findElements('link').first.text,
            'streaming_url': item.findElements('streaming_url').first.text,
            'image': item.findElements('image').first.text,
            'description': item.findElements('description').isEmpty
                ? 'No description available'
                : item.findElements('description').first.text,
          };
        }).toList();
      } else {
        log('Failed to load stations: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching stations: $e');
    } finally {
      isLoading(false);
    }
  }

  void playPause(String streamUrl, int index) async {
    try {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (!hasConnection) {
        Get.snackbar('No Internet Connection', 'Please check your internet connection.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (currentStreamUrl.value.isEmpty || currentStreamUrl.value != streamUrl) {
        await audioPlayer.stop();
        isPlaying(false);

        await audioPlayer.setSourceUrl(streamUrl);
        await audioPlayer.resume();
        isPlaying(true);
        currentStreamUrl.value = streamUrl;
        currentStation.value = stations[index];
        currentIndex.value = index;

        firstPlay(true);

        AwesomeNotificationService().showOrUpdateNotification(currentStation['title'] ?? 'Radio Station', isPlaying.value);
        log('Playback started successfully for: $streamUrl');
      } else {
        if (isPlaying.value) {
          await audioPlayer.pause();
          isPlaying(false);
          AwesomeNotificationService().showOrUpdateNotification(currentStation['title'] ?? 'Radio Station', false);
        } else {
          await audioPlayer.resume();
          isPlaying(true);
          AwesomeNotificationService().showOrUpdateNotification(currentStation['title'] ?? 'Radio Station', true);
        }
      }
    } catch (e) {
      log('Error playing stream: $e');
      Get.snackbar('Playback Issue', 'Could not play the stream. Please try again later.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void previousStation() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      playPause(stations[currentIndex.value]['streaming_url']!, currentIndex.value);
    } else {
      Get.snackbar('Info', 'This is the first station.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void nextStation() {
    if (currentIndex.value < stations.length - 1) {
      currentIndex.value++;
      playPause(stations[currentIndex.value]['streaming_url']!, currentIndex.value);
    } else {
      Get.snackbar('Info', 'This is the last station.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void closeAudio() {
    audioPlayer.stop();
    isPlaying(false);
    AwesomeNotificationService().cancelNotification();
  }

  void pauseAudio() {
    audioPlayer.pause();
    isPlaying(false);
    AwesomeNotificationService().showOrUpdateNotification(
        currentStation['title'] ?? 'Radio Station', false
    );
  }

  void resumeAudio() {
    audioPlayer.resume();
    isPlaying(true);
    AwesomeNotificationService().showOrUpdateNotification(
        currentStation['title'] ?? 'Radio Station', true
    );
  }

  void toggleMute() {
    if (isMuted.value) {
      audioPlayer.setVolume(volume.value);
      isMuted(false);
    } else {
      audioPlayer.setVolume(0.0);
      isMuted(true);
    }
  }

  void setVolume(double value) {
    volume.value = value;
    if (!isMuted.value) {
      audioPlayer.setVolume(value);
    }
    log('Volume set to: $value');
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    audioPlayer.dispose();

    AwesomeNotificationService().cancelNotification();

    super.dispose();
  }
}
