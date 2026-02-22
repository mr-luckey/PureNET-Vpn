import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/config.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../screens/location_screen.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/reward_ad_service.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;

  final vpnState = VpnEngine.vpnDisconnected.obs;

  void connectToVpn() async {
    print('[DEBUG] connectToVpn: ENTRY - vpnState=${vpnState.value}, country=${vpn.value.countryLong}');

    if (vpn.value.openVPNConfigDataBase64.isEmpty) {
      print('[DEBUG] connectToVpn: No location selected, redirecting to LocationScreen');
      Get.to(() => LocationScreen());
      return;
    }

    final rewardService = RewardAdService();

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      if (Config.hideAds) {
        final vpnConfig = VpnConfig(
            country: vpn.value.countryLong,
            username: 'vpn',
            password: 'vpn',
            config: Utf8Decoder().convert(
                Base64Decoder().convert(vpn.value.openVPNConfigDataBase64)));
        await VpnEngine.startVpn(vpnConfig);
        return;
      }

      print('[DEBUG] connectToVpn: Loading ad, then show reward ad...');
      MyDialogs.showProgress();

      final adReady = await rewardService.waitForAdReady();
      Get.back(); // hide loading

      if (!adReady) {
        MyDialogs.info(msg: 'Ad could not load. Please try again.');
        return;
      }

      final vpnConfig = VpnConfig(
          country: vpn.value.countryLong,
          username: 'vpn',
          password: 'vpn',
          config: Utf8Decoder().convert(
              Base64Decoder().convert(vpn.value.openVPNConfigDataBase64)));

      rewardService.showAd(
        onRewardGranted: () async {
          print('[DEBUG] connectToVpn: Reward granted, connecting VPN...');
          await VpnEngine.startVpn(vpnConfig);
        },
        onAdNotAvailable: () {
          MyDialogs.info(msg: 'Ad not available. Please try again.');
        },
      );
    } else {
      if (Config.hideAds) {
        await VpnEngine.stopVpn();
        return;
      }

      print('[DEBUG] connectToVpn: Loading ad, then show reward ad...');
      MyDialogs.showProgress();

      final adReady = await rewardService.waitForAdReady();
      Get.back(); // hide loading

      if (!adReady) {
        MyDialogs.info(msg: 'Ad could not load. Please try again.');
        return;
      }

      rewardService.showAd(
        onRewardGranted: () async {
          print('[DEBUG] connectToVpn: Reward granted, disconnecting VPN...');
          await VpnEngine.stopVpn();
        },
        onAdNotAvailable: () {
          MyDialogs.info(msg: 'Ad not available. Please try again.');
        },
      );
    }
  }

  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.white;

      case VpnEngine.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Tap to Connect';

      case VpnEngine.vpnConnected:
        return 'Disconnect';

      default:
        return 'Connecting...';
    }
  }
}
