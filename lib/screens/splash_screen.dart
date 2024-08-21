import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';

import '../helpers/ad_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();


      Get.off(() => HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {

    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0x004AAD),
      body: Container(
        color: Color(0xFF004AAD),
          height: Get.height,
          width: Get.width,
          child: Center(child: Image.asset('assets/images/applogo5.png'))),
    );
  }
}
