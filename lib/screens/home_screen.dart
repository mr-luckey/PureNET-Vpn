import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../controllers/home_controller.dart';
import '../main.dart';

import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  // final CountryController _countryController = Get.put(CountryController());
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Stack(
      children: [
        Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   title: Text('PureNet VPN'),
          //   actions: [
          //     IconButton(
          //         padding: EdgeInsets.only(right: 8),
          //         onPressed: () => Get.to(() => NetworkTestScreen()),
          //         icon: Icon(
          //           CupertinoIcons.info,
          //           size: 27,
          //         )),
          //   ],
          // ),
          bottomNavigationBar: _changeLocation(context),
          backgroundColor: Color(0xFF004AAD),
          body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: Get.height * .05,
                  ),
                  SizedBox(
                    height: Get.height * .05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Get.width * .17,
                        ),
                        Text('PureNet VPN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w500)),
                        IconButton(
                            padding: EdgeInsets.only(right: 8),
                            onPressed: () => Get.to(() => NetworkTestScreen()),
                            icon: Icon(
                              CupertinoIcons.info,
                              size: 27,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Obx(() => _vpnButton()),
                  SizedBox(
                    height: 60,
                  ),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        HomeCard(
                            title: _controller.vpn.value.countryLong.isEmpty
                                ? 'Country'
                                : _controller.vpn.value.countryLong,
                            subtitle: 'FREE',
                            icon: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: _controller.vpn.value.countryLong.isEmpty
                                  ? Icon(Icons.vpn_lock_rounded,
                                      size: 30, color: Colors.white)
                                  : null,
                              backgroundImage: _controller
                                      .vpn.value.countryLong.isEmpty
                                  ? null
                                  : AssetImage(
                                      'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        HomeCard(
                            title: _controller.vpn.value.countryLong.isEmpty
                                ? '100 ms'
                                : '${_controller.vpn.value.ping} ms',
                            subtitle: 'PING',
                            icon: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.equalizer_rounded,
                                  size: 30, color: Colors.white),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  StreamBuilder<VpnStatus?>(
                      initialData: VpnStatus(),
                      stream: VpnEngine.vpnStatusSnapshot(),
                      builder: (context, snapshot) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //download
                              HomeCard(
                                  title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                                  subtitle: 'DOWNLOAD',
                                  icon: CircleAvatar(
                                      radius: 30,
                                      // backgroundColor: Colors.lightGreen,
                                      child: Image.asset(
                                          "assets/images/logo1.png"))),

                              //upload
                              HomeCard(
                                title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                                subtitle: 'UPLOAD',
                                icon: CircleAvatar(
                                    radius: 30,
                                    // backgroundColor: Colors.blue,
                                    child:
                                        Image.asset("assets/images/logo3.png")),
                              ),
                            ],
                          ))
                ]),
          ),
        )
      ],
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
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 28,
                          color: Color(0xFF004AAD),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _controller.getButtonText,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF004AAD),
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF004AAD),
              ),
            ),
          ),
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              color: Color(0xFF004AAD),
              padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
              height: 60,
              child: Row(
                children: [
                  Icon(CupertinoIcons.globe, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Obx(() {
                    final locationText =
                        _controller.vpn.value.countryLong.isNotEmpty
                            ? 'Change Location: ' +
                                _controller.vpn.value.countryLong
                            : 'No server selected';
                    return Text(
                      locationText,
                      // _controller.vpn.value.countryLong,
                      // 'Change Location: ${_countryController.selectedCountry}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.keyboard_arrow_right_rounded,
                        color: Colors.blue, size: 26),
                  )
                ],
              )),
        ),
      ));
}
