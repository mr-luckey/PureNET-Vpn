import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/config.dart';
import '../main.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _controller = LocationController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    final _adController = Get.put(NativeAdController());
    if (!Config.hideAds &&
        _adController.ad == null &&
        !_adController.adLoaded.value) {
      AdHelper.loadNativeAd(adController: _adController);
    }

    return Stack(
      children: [
        Obx(
          () => Scaffold(
            backgroundColor: Color(0xFF004AAD),
            bottomNavigationBar: !Config.hideAds &&
                    _adController.ad != null &&
                    _adController.adLoaded.value
                ? SafeArea(
                    child: SizedBox(
                        height: 85,
                        child: AdWidget(ad: _adController.ad!)))
                : null,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 10),
              child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () => _controller.getVpnData(),
                  child:
                      Icon(CupertinoIcons.refresh, color: Color(0xFF004AAD))),
            ),
            body: _controller.isLoading.value
                ? _loadingWidget()
                : _controller.vpnList.isEmpty
                    ? _noVPNFound()
                    : _vpnData(),
          ),
        )
      ],
    );
  }

  _vpnData() => Column(
        children: [
          SizedBox(
            height: Get.height * 0.05,
          ),
          SizedBox(
            height: Get.height * 0.05,
            child: Center(
              child: Text(
                'VPN Locations (${_controller.vpnList.length})',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: Get.height * 0.78,
            child: ListView.builder(
                itemCount: _controller.vpnList.length,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    top: mq.height * .015,
                    bottom: mq.height * .1,
                    left: mq.width * .04,
                    right: mq.width * .04),
                itemBuilder: (ctx, i) => VpnCard(vpn: _controller.vpnList[i])),
          ),
        ],
      );

  _loadingWidget() => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset('assets/lottie/loading.json',
                width: mq.width * .7),
            Text(
              'Loading VPNs... ',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            )
          ],
        ),
      );

  _noVPNFound() => Center(
        child: Text(
          'VPNs Not Found! ',
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
}
