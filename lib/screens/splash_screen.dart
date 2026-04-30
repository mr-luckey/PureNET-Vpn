import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';

import '../helpers/ad_helper.dart';
import '../main.dart';
import '../services/theme_service.dart';
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
      backgroundColor: AppTheme.backgroundPrimary,
      body: Container(
        color: AppTheme.backgroundPrimary,
        height: Get.height,
        width: Get.width,
        child: Center(
          child: SvgPicture.asset(
            'assets/images/applogo5.png',
            width: 220,
            height: 220,
          ),
        ),
      ),
    );
  }
}
