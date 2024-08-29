import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_app/views/routes/AppRoutes.dart';
import 'package:radio_app/views/utils/ImageUtils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.HOMEPAGE);
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageUtils.ImagePath + ImageUtils.SplashScreenBg,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    ImageUtils.ImagePath + ImageUtils.AppIcon,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
