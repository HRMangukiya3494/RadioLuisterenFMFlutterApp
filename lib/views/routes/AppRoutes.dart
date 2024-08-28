import 'package:get/get.dart';
import 'package:radio_app/views/screens/SplashScreen.dart';

class AppRoutes {
  static const String SPLASH = "/";

  static final routes = [
    GetPage(
      name: SPLASH,
      page: () => SplashScreen(),
    ),
  ];
}
