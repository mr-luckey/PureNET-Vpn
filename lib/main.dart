import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/splash_screen.dart';
import 'services/theme_service.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Config.initConfig();

  await Pref.initializeHive();

  await AdHelper.initAds();

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
      theme: AppTheme.lightTheme,
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
