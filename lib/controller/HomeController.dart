import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class HomeController extends GetxController {
  var isLoading = true.obs;
  var stations = <Map<String, String>>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  var currentStreamUrl = ''.obs;
  var currentStation = <String, String>{}.obs;
  var currentIndex = 0.obs;
  var isPlaying = false.obs;
  var firstPlay = false.obs;

  @override
  void onInit() {
    fetchStations();
    super.onInit();
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

        log('Playback started successfully for: $streamUrl');
      } else {
        if (isPlaying.value) {
          await audioPlayer.pause();
          isPlaying(false);
        } else {
          await audioPlayer.resume();
          isPlaying(true);
        }
      }
    } catch (e) {
      log('Error playing stream: $e');
      Get.snackbar('Playback Issue', 'Could not play the stream. Please try again later.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void nextStation() {
    int nextIndex = currentIndex.value + 1;
    if (nextIndex >= stations.length) {
      nextIndex = 0;
    }
    playPause(stations[nextIndex]['streaming_url']!, nextIndex);
  }

  void previousStation() {
    int prevIndex = currentIndex.value - 1;
    if (prevIndex < 0) {
      prevIndex = stations.length - 1;
    }
    playPause(stations[prevIndex]['streaming_url']!, prevIndex);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
