import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controllers/home_controller.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../services/theme_service.dart';

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: mq.height * .012),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: AppTheme.cardBackground,
      child: InkWell(
        onTap: () {
          Get.back();
          controller.connectToServer(vpn);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppTheme.cardBackground,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.accentBlue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SvgPicture.asset(
                    'assets/flags/${vpn.countryShort.toLowerCase()}.svg',
                    height: 45,
                    width: mq.width * .15,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vpn.countryLong,
                      style: AppTheme.comfortaaTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.speed_rounded,
                            color: AppTheme.accentBlue, size: 18),
                        SizedBox(width: 4),
                        Text(
                          _formatBytes(vpn.speed, 1),
                          style: AppTheme.comfortaaTextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vpn.numVpnSessions.toString(),
                    style: AppTheme.comfortaaTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(CupertinoIcons.person_3,
                      color: AppTheme.accentBlue, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
