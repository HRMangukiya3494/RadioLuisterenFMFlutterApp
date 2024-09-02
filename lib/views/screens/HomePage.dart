import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_app/controller/HomeController.dart';
import 'package:radio_app/views/utils/ImageUtils.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageUtils.ImagePath + ImageUtils.BGImage,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: h * 0.01),
                Container(
                  height: h * 0.04,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        ImageUtils.ImagePath + ImageUtils.AppIcon,
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                SizedBox(height: h * 0.01),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (controller.stations.isEmpty) {
                      return Center(
                        child: Text(
                          'No Connection',
                          style: TextStyle(
                            color: Color(0xff0E364D),
                            fontWeight: FontWeight.bold,
                            fontSize: h * 0.024,
                          ),
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double itemHeight = (constraints.maxWidth - 16.0) / 3;
                        double itemWidth = itemHeight * 1.5;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: itemWidth / itemHeight,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                          itemCount: controller.stations.length,
                          itemBuilder: (context, index) {
                            final station = controller.stations[index];
                            final imageUrl = station['image'] ?? '';
                            final streamingUrl = station['streaming_url'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                if (streamingUrl.isNotEmpty) {
                                  controller.playPause(streamingUrl, index);
                                } else {
                                  log('No streaming URL provided for this station.');
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8.0,
                                      offset: Offset(2, 4),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
                Obx(() {
                  if (controller.firstPlay.value) {
                    return BottomAppBar(
                      height: h * 0.1,
                      color: Colors.white.withOpacity(0.4),
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.all(h * 0.01),
                        child: Row(
                          children: [
                            // Container for the image and title
                            if (controller.currentStation['image'] != null)
                              Container(
                                height: h * 0.06,
                                width: h * 0.06,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: h * 0.002,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      controller.currentStation['image']!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (controller.currentStation['title'] != null)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    controller.currentStation['title']!,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.playPause(
                                        controller.currentStreamUrl.value,
                                        controller.currentIndex.value);
                                  },
                                  child: Container(
                                    height: h * 0.06,
                                    width: h * 0.06,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFEB458C),
                                          Color(0xFF8648F3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        controller.isPlaying.value
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.toggleMute();
                                  },
                                  child: Container(
                                    height: h * 0.08,
                                    width: h * 0.08,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFEB458C),
                                          Color(0xFF8648F3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Obx(() {
                                        return Icon(
                                          controller.volume.value == 0 ||
                                                  controller.isMuted.value
                                              ? Icons.volume_off
                                              : Icons.volume_up,
                                          color: Colors.white,
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  return Container(
                                    width: h * 0.2,
                                    // Adjust width for responsiveness
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Slider(
                                      value: controller.volume.value,
                                      // Bind slider to volume
                                      min: 0,
                                      max: 1,
                                      onChanged: (value) {
                                        controller
                                            .setVolume(value); // Update volume
                                      },
                                      activeColor: Color(0xFF8648F3),
                                      inactiveColor: Colors.grey,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
