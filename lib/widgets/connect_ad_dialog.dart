import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectAdDialog extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onConnectWithAd;

  const ConnectAdDialog({
    super.key,
    required this.onWatchAd,
    required this.onConnectWithAd,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Connect to VPN'),
      content: Text(
        'Watch a short ad to connect without an ad, or connect now and see an ad.',
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          textStyle: TextStyle(color: Colors.green),
          child: Text('Watch Ad'),
          onPressed: () {
            Get.back();
            onWatchAd();
          },
        ),
        CupertinoDialogAction(
          child: Text('Connect with Ad'),
          onPressed: () {
            Get.back();
            onConnectWithAd();
          },
        ),
      ],
    );
  }
}
