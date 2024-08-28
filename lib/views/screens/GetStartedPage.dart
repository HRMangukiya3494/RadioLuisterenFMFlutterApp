import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_app/views/routes/AppRoutes.dart';
import 'package:radio_app/views/utils/ColorUtils.dart';
import 'package:radio_app/views/utils/ImageUtils.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                ImageUtils.ImagePath + ImageUtils.GetStartedBg,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              h * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "From the ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: h * 0.026,
                        ),
                      ),
                      TextSpan(
                        text: "latest",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.primaryColor,
                          fontSize: h * 0.026,
                        ),
                      ),
                      TextSpan(
                        text: " to the ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: h * 0.026,
                        ),
                      ),
                      TextSpan(
                        text: "greatest",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.primaryColor,
                          fontSize: h * 0.026,
                        ),
                      ),
                      TextSpan(
                        text: " hits, play your ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: h * 0.026,
                        ),
                      ),
                      TextSpan(
                        text: "favorite tracks on Radio",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: h * 0.026,
                        ),
                      ),
                      TextSpan(
                        text: "Luisteren",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.primaryColor,
                          fontSize: h * 0.024,
                        ),
                      ),
                      TextSpan(
                        text: ".fm Now !!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: h * 0.026,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.04,
                ),
                Container(
                  height: h * 0.006,
                  width: w / 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      h * 0.01,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Red half
                      Container(
                        height: h * 0.006,
                        width: (w / 4) / 2,
                        decoration: BoxDecoration(
                          color: ColorUtils.primaryColor,
                          borderRadius: BorderRadius.circular(
                            h * 0.01,
                          ),
                        ),
                      ),
                      // White half
                      Container(
                        height: h * 0.006,
                        width: (w / 4) / 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            h * 0.01,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.04,
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAllNamed(AppRoutes.HOMEPAGE);
                  },
                  child: Container(
                    height: h * 0.06,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0E364D),
                          Color(0xFF7B49FF).withOpacity(0.61),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD4B7C9),
                          offset: Offset(0, 0),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(
                        h * 0.04,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: h * 0.02,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: h * 0.06,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
