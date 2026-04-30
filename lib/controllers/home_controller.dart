import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/theme_service.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;
  final RxBool autoConnectEnabled = Pref.autoConnectEnabled.obs;

  final vpnState = VpnEngine.vpnDisconnected.obs;

  Future<void> connectToVpn({bool allowAutoSelection = true}) async {
    final selectedVpn = await _resolveVpnSelection(allowAutoSelection);
    if (selectedVpn == null) return;
    final vpnConfig = _buildVpnConfig(selectedVpn);
    if (vpnConfig == null) {
      MyDialogs.error(
          msg:
              'Selected server has invalid configuration. Please try another.');
      return;
    }
    await VpnEngine.startVpn(vpnConfig);
    if (vpnState.value != VpnEngine.vpnDisconnected) {
      await VpnEngine.stopVpn();
      return;
    }
  }

  Future<void> connectToServer(Vpn target) async {
    _disableAutoConnectMode();
    vpn.value = target;
    Pref.vpn = target;

    if (vpnState.value == VpnEngine.vpnConnected) {
      await VpnEngine.stopVpn();
      Future.delayed(const Duration(seconds: 2),
          () => connectToVpn(allowAutoSelection: false));
    } else {
      await connectToVpn(allowAutoSelection: false);
    }
  }

  Future<void> connectToBestAvailableServer() async {
    final bestServer = await _findBestServer();
    if (bestServer == null) {
      MyDialogs.info(
          msg:
              'No optimized server available right now. Please refresh and try again.');
      return;
    }

    await connectToServer(bestServer);
  }

  Future<Vpn?> _resolveVpnSelection(bool allowAutoSelection) async {
    if (autoConnectEnabled.value) {
      return await _findBestServerWithFeedback();
    }

    if (vpn.value.openVPNConfigDataBase64.isNotEmpty) return vpn.value;

    if (!allowAutoSelection) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return null;
    }

    return await _findBestServerWithFeedback(storeSelection: true);
  }

  Future<Vpn?> _findBestServer() async {
    List<Vpn> availableServers = Pref.vpnList;

    if (availableServers.isEmpty) {
      availableServers = await APIs.getVPNServers();
    }

    availableServers = availableServers
        .where((element) => element.openVPNConfigDataBase64.isNotEmpty)
        .toList();

    if (availableServers.isEmpty) return null;

    availableServers.sort((a, b) {
      final pingA = int.tryParse(a.ping) ?? 999999;
      final pingB = int.tryParse(b.ping) ?? 999999;
      if (pingA != pingB) return pingA.compareTo(pingB);
      return b.speed.compareTo(a.speed);
    });

    return availableServers.first;
  }

  Future<Vpn?> _findBestServerWithFeedback(
      {bool storeSelection = false}) async {
    final bestServer = await _findBestServer();
    if (bestServer == null) {
      MyDialogs.info(
          msg:
              'Unable to find a server automatically. Try refreshing the server list.');
      return null;
    }

    if (storeSelection) {
      vpn.value = bestServer;
      Pref.vpn = bestServer;
    }
    return bestServer;
  }

  VpnConfig? _buildVpnConfig(Vpn vpn) {
    try {
      final data = Base64Decoder().convert(vpn.openVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);
      return VpnConfig(
          country: vpn.countryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);
    } catch (_) {
      return null;
    }
  }

  void enableAutoConnectMode() {
    autoConnectEnabled.value = true;
    Pref.autoConnectEnabled = true;
    _clearSelectedVpn();
  }

  void _disableAutoConnectMode() {
    if (autoConnectEnabled.value) {
      autoConnectEnabled.value = false;
      Pref.autoConnectEnabled = false;
    }
  }

  void _clearSelectedVpn() {
    final emptyVpn = Vpn.fromJson({});
    vpn.value = emptyVpn;
    Pref.vpn = emptyVpn;
  }

  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return AppTheme.disconnectedWhite;

      case VpnEngine.vpnConnected:
        return AppTheme.connectedGreen;

      default:
        return AppTheme.connectingOrange;
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
