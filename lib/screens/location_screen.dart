import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

import '../controllers/home_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../main.dart';
import '../services/theme_service.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _controller = LocationController();
  final _homeController = Get.find<HomeController>();
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      bottomNavigationBar:
          _adController.ad != null && _adController.adLoaded.isTrue
              ? SafeArea(
                  child: SizedBox(
                    height: 85,
                    child: AdWidget(ad: _adController.ad!),
                  ),
                )
              : null,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentBlue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppTheme.accentBlue,
          onPressed: () => _controller.getVpnData(),
          child: Icon(
            CupertinoIcons.refresh,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Obx(
        () => _controller.isLoading.value
            ? _loadingWidget()
            : _controller.vpnList.isEmpty
                ? _noVPNFound()
                : _vpnData(),
      ),
    );
  }

  _vpnData() => Column(
        children: [
          SizedBox(height: Get.height * 0.05),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: Text(
              'VPN Locations (${_controller.vpnList.length})',
              style: AppTheme.comfortaaTextStyle(
                fontSize: 26,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.02),
          Expanded(
            child: Obx(() {
              final isAutoSelected = _homeController.autoConnectEnabled.value;
              return ListView.builder(
                itemCount: _controller.vpnList.length + 1,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: mq.height * .015,
                  bottom: mq.height * .1,
                  left: mq.width * .05,
                  right: mq.width * .05,
                ),
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return _AutoConnectCard(
                      isSelected: isAutoSelected,
                      onTap: () {
                        _homeController.enableAutoConnectMode();
                        Get.back();
                      },
                    );
                  }
                  return VpnCard(vpn: _controller.vpnList[i - 1]);
                },
              );
            }),
          ),
        ],
      );

  _loadingWidget() => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/lottie/loading.json',
              width: mq.width * .7,
            ),
            SizedBox(height: 20),
            Text(
              'Loading VPNs...',
              style: AppTheme.comfortaaTextStyle(
                fontSize: 18,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      );

  _noVPNFound() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'VPNs Not Found!',
              style: AppTheme.comfortaaTextStyle(
                fontSize: 20,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}

class _AutoConnectCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AutoConnectCard({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: mq.height * .02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: AppTheme.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppTheme.connectedGreen
                  : AppTheme.connectedGreen.withOpacity(0.3),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.connectedGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.bolt_horizontal,
                  color: AppTheme.connectedGreen,
                  size: 26,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Connect',
                      style: AppTheme.comfortaaTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Let PureNet find the fastest server',
                      style: AppTheme.comfortaaTextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.arrow_right_circle_fill,
                color: AppTheme.connectedGreen,
                size: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
