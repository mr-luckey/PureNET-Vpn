import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';

class WatchAdDialog extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdDialog({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        'Change Theme',
        style: AppTheme.comfortaaTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      content: Text(
        'Watch an Ad to Change App Theme.',
        style: AppTheme.comfortaaTextStyle(
          fontSize: 14,
          color: AppTheme.textDark,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          textStyle: AppTheme.comfortaaTextStyle(
            color: AppTheme.connectedGreen,
            fontWeight: FontWeight.w600,
          ),
          child: Text('Watch Ad'),
          onPressed: () {
            Get.back();
            onComplete();
          },
        ),
      ],
    );
  }
}
