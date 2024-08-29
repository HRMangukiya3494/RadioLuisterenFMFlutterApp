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
                SizedBox(
                  height: h * 0.01,
                ),
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
                SizedBox(
                  height: h * 0.01,
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (controller.stations.isEmpty) {
                      return Center(
                        child: Text(
                          'No stations available',
                          style: TextStyle(),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of images per row
                        childAspectRatio: 1, // Aspect ratio for square images
                        mainAxisSpacing: 8.0, // Space between rows
                        crossAxisSpacing: 8.0, // Space between columns
                      ),
                      itemCount: controller.stations.length,
                      itemBuilder: (context, index) {
                        final station = controller.stations[index];
                        final imageUrl = station['image'] ?? '';
                        final streamingUrl = station['streaming_url'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            if (streamingUrl.isNotEmpty) {
                              controller.playPause(streamingUrl);
                            } else {
                              log('No streaming URL provided for this station.');
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.all(8.0), // Margin around each image
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover, // Ensures the image covers the entire container
                              ),
                              borderRadius: BorderRadius.circular(12.0), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26, // Shadow color
                                  blurRadius: 8.0, // Softness of the shadow
                                  offset: Offset(2, 4), // Position of the shadow
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
