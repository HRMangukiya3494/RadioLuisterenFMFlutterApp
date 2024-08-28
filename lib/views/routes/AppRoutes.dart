import 'package:get/get.dart';
import 'package:radio_app/views/screens/GetStartedPage.dart';
import 'package:radio_app/views/screens/HomePage.dart';
import 'package:radio_app/views/screens/SplashScreen.dart';

class AppRoutes {
  static const String SPLASH = "/";
  static const String GETSTARTED = "/get_started_page";
  static const String HOMEPAGE = "/home";

  static final routes = [
    GetPage(
      name: SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: GETSTARTED,
      page: () => GetStartedPage(),
    ),
    GetPage(
      name: HOMEPAGE,
      page: () => HomePage(),
    ),
  ];
}
