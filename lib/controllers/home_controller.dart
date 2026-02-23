import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/ad_helper.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../screens/location_screen.dart';
import '../services/vpn_engine.dart';
import '../widgets/connect_ad_dialog.dart';

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

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      print('[DEBUG] connectToVpn: Building VPN config...');
      final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);
      print('[DEBUG] connectToVpn: Config decoded, length=${config.length} chars');
      final vpnConfig = VpnConfig(
          country: vpn.value.countryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);

      Get.dialog(
        ConnectAdDialog(
          onWatchAd: () {
            AdHelper.showRewardedAd(
              onComplete: () async {
                await VpnEngine.startVpn(vpnConfig);
              },
              onSkipped: () {},
            );
          },
          onConnectWithAd: () {
            AdHelper.showInterstitialAd(onComplete: () async {
              await VpnEngine.startVpn(vpnConfig);
            });
          },
        ),
      );
    } else {
      print('[DEBUG] connectToVpn: Calling VpnEngine.stopVpn()');
      await VpnEngine.stopVpn();
      print('[DEBUG] connectToVpn: VpnEngine.stopVpn() completed');
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
