import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class HomeController extends GetxController {
  var isLoading = true.obs;
  var stations = <Map<String, String>>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  var currentStreamUrl = ''.obs;
  var isPlaying = false.obs;

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

  void playPause(String streamUrl) async {
    try {
      if (currentStreamUrl.value == streamUrl) {
        if (isPlaying.value) {
          await audioPlayer.pause();
          isPlaying(false);
        } else {
          await audioPlayer.play();
          isPlaying(true);
        }
      } else {
        // Load and play the new stream
        await audioPlayer.setUrl(streamUrl);
        await audioPlayer.play();
        isPlaying(true);
        currentStreamUrl.value = streamUrl;
        log('Playback started successfully for: $streamUrl');
      }
    } catch (e) {
      log('Error playing stream: $e');
      Get.snackbar('Playback Error', 'Could not play the stream. Please try again later.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }





  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
