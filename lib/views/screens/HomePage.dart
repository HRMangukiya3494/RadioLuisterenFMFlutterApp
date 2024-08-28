import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_app/controller/HomeController.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radio Stations'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.stations.isEmpty) {
          return Center(child: Text('No stations available'));
        }

        return ListView.builder(
          itemCount: controller.stations.length,
          itemBuilder: (context, index) {
            final station = controller.stations[index];
            final imageUrl = station['image'] ?? 'https://via.placeholder.com/150';
            final title = station['title'] ?? 'No Title';
            final description = station['description'] ?? 'No description available';
            final streamingUrl = station['streaming_url'] ?? '';

            return Padding(padding: EdgeInsets.all(16,),child:  Card(child: ListTile(
              leading: Image.network(imageUrl),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(description),
              trailing: Obx(() {
                final isCurrent = controller.isPlaying.value && controller.currentStreamUrl.value == streamingUrl;
                return IconButton(
                  icon: Icon(
                    isCurrent ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: isCurrent ? Colors.green : Colors.blue,
                    size: 30.0,
                  ),
                  onPressed: () {
                    if (streamingUrl.isNotEmpty) {
                      controller.playPause(streamingUrl);
                    } else {
                      log('No streaming URL provided for this station.');
                    }
                  },
                );
              }),
              onTap: () {
                if (streamingUrl.isNotEmpty) {
                  controller.playPause(streamingUrl);
                } else {
                  log('No streaming URL provided for this station.');
                }
              },
            ),),);
          },
        );
      }),
    );
  }
}
