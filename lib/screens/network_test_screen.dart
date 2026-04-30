import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../main.dart';
import '../models/ip_details.dart';
import '../models/network_data.dart';
import '../services/theme_service.dart';
import '../widgets/network_card.dart';

class NetworkTestScreen extends StatelessWidget {
  const NetworkTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ipData = IPDetails.fromJson({}).obs;
    APIs.getIPDetails(ipData: ipData);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          'Network Information',
          style: AppTheme.comfortaaTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.backgroundPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
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
          onPressed: () {
            ipData.value = IPDetails.fromJson({});
            APIs.getIPDetails(ipData: ipData);
          },
          child: Icon(CupertinoIcons.refresh, color: AppTheme.textPrimary),
        ),
      ),
      body: Obx(
        () => ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            mq.width * .05,
            mq.height * .02,
            mq.width * .05,
            mq.height * .1,
          ),
          children: [
            NetworkCard(
              data: NetworkData(
                  title: 'IP Address',
                  subtitle: ipData.value.query.isEmpty
                      ? 'Fetching...'
                      : ipData.value.query,
                  icon: Icon(CupertinoIcons.location_solid,
                      color: AppTheme.accentBlue)),
            ),
            NetworkCard(
              data: NetworkData(
                  title: 'Internet Provider',
                  subtitle: ipData.value.isp.isEmpty
                      ? 'Fetching...'
                      : ipData.value.isp,
                  icon: Icon(Icons.business, color: AppTheme.connectingOrange)),
            ),
            NetworkCard(
              data: NetworkData(
                  title: 'Location',
                  subtitle: ipData.value.country.isEmpty
                      ? 'Fetching...'
                      : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                  icon: Icon(CupertinoIcons.location,
                      color: AppTheme.lightAccentBlue)),
            ),
            NetworkCard(
              data: NetworkData(
                  title: 'Pin-code',
                  subtitle: ipData.value.zip.isEmpty
                      ? 'Fetching...'
                      : ipData.value.zip,
                  icon: Icon(CupertinoIcons.location_solid,
                      color: AppTheme.accentBlue)),
            ),
            NetworkCard(
              data: NetworkData(
                  title: 'Timezone',
                  subtitle: ipData.value.timezone.isEmpty
                      ? 'Fetching...'
                      : ipData.value.timezone,
                  icon: Icon(CupertinoIcons.time,
                      color: AppTheme.connectedGreen)),
            ),
          ],
        ),
      ),
    );
  }
}
