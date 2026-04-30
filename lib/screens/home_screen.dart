import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../controllers/home_controller.dart';
import '../main.dart';

import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../services/theme_service.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.05,
                  vertical: mq.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: mq.width * 0.1),
                    Expanded(
                      child: Center(
                        child: Text(
                          'PureNet VPN',
                          style: AppTheme.comfortaaTextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Get.to(() => NetworkTestScreen()),
                      icon: Icon(
                        CupertinoIcons.info_circle,
                        color: AppTheme.textPrimary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: mq.height * 0.03),

              // VPN Button Section
              Obx(() => _vpnButton()),

              SizedBox(height: mq.height * 0.04),

              // Country and Ping Cards
              Obx(() {
                final isAutoConnect = _controller.autoConnectEnabled.value;
                final selectedVpn = _controller.vpn.value;
                final hasSelection = selectedVpn.countryLong.isNotEmpty;
                final countryTitle = isAutoConnect
                    ? 'Auto Connect'
                    : hasSelection
                        ? selectedVpn.countryLong
                        : 'Country';
                final pingTitle = isAutoConnect
                    ? 'Fastest'
                    : hasSelection
                        ? '${selectedVpn.ping} ms'
                        : '100 ms';
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HomeCard(
                        title: countryTitle,
                        subtitle: isAutoConnect ? 'AUTO' : 'FREE',
                        icon: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.accentBlue,
                          child: (!hasSelection || isAutoConnect)
                              ? Icon(Icons.vpn_lock_rounded,
                                  size: 32, color: AppTheme.textPrimary)
                              : ClipOval(
                                  child: SvgPicture.asset(
                                    'assets/flags/${selectedVpn.countryShort.toLowerCase()}.svg',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      HomeCard(
                        title: pingTitle,
                        subtitle: isAutoConnect ? 'OPTIMAL' : 'PING',
                        icon: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.connectingOrange,
                          child: Icon(Icons.equalizer_rounded,
                              size: 32, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: mq.height * 0.04),

              // Download and Upload Cards
              StreamBuilder<VpnStatus?>(
                initialData: VpnStatus(),
                stream: VpnEngine.vpnStatusSnapshot(),
                builder: (context, snapshot) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HomeCard(
                        title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                        subtitle: 'DOWNLOAD',
                        icon: CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppTheme.connectedGreen.withOpacity(0.3),
                          child: SvgPicture.asset(
                            "assets/images/logo1.svg",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      HomeCard(
                        title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                        subtitle: 'UPLOAD',
                        icon: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.accentBlue.withOpacity(0.3),
                          child: SvgPicture.asset(
                            "assets/images/logo3.svg",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: mq.height * 0.05),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _changeLocation(context),
    );
  }

  Widget _vpnButton() => Column(
        children: [
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _controller.getButtonColor.withOpacity(0.15),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(0.25),
                  ),
                  child: Container(
                    width: mq.height * 0.16,
                    height: mq.height * 0.16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor,
                      boxShadow: [
                        BoxShadow(
                          color: _controller.getButtonColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new_rounded,
                          size: 36,
                          color: _controller.vpnState.value ==
                                  VpnEngine.vpnDisconnected
                              ? AppTheme.primaryBlue
                              : AppTheme.textPrimary,
                        ),
                        SizedBox(height: 6),
                        Text(
                          _controller.getButtonText,
                          style: AppTheme.comfortaaTextStyle(
                            fontSize: 11,
                            color: _controller.vpnState.value ==
                                    VpnEngine.vpnDisconnected
                                ? AppTheme.primaryBlue
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: mq.height * 0.02,
              bottom: mq.height * 0.015,
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: AppTheme.comfortaaTextStyle(
                fontSize: 13,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(
            () => CountDownTimer(
              startTimer: _controller.vpnState.value == VpnEngine.vpnConnected,
            ),
          ),
        ],
      );

  Widget _changeLocation(BuildContext context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundPrimary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Semantics(
            button: true,
            child: InkWell(
              onTap: () => Get.to(() => LocationScreen()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.05,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.globe,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final isAutoConnect =
                            _controller.autoConnectEnabled.value;
                        final hasSelection =
                            _controller.vpn.value.countryLong.isNotEmpty;
                        final locationText = isAutoConnect
                            ? 'Auto Connect'
                            : hasSelection
                                ? 'Change Location: ${_controller.vpn.value.countryLong}'
                                : 'No server selected';
                        return Text(
                          locationText,
                          style: AppTheme.comfortaaTextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
