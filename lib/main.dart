import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/services/ads_helper.dart';

import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/splash_screen.dart';
import 'services/reward_ad_service.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Config.initConfig();

  await Pref.initializeHive();

  await MobileAds.instance.initialize();
  AdManager().initialize();
  RewardAdService().initialize();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PureNET VPN',
      home: SplashScreen(),
      theme:
          ThemeData(appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.dark,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText =>
      Pref.isDarkMode ? Color(0xFF004AAD) : Color(0xFF004AAD);
  Color get bottomNav =>
      Pref.isDarkMode ? Color.fromARGB(255, 40, 39, 39) : Colors.blue;
}
