import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDialogs {
  static void _safeSnackbar(void Function() show) {
    if (Get.overlayContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.overlayContext != null) show();
      });
    }
  }

  static success({required String msg}) {
    _safeSnackbar(() => Get.snackbar('Success', msg,
        colorText: Colors.white, backgroundColor: Colors.green.withOpacity(.9)));
  }

  static error({required String msg}) {
    _safeSnackbar(() => Get.snackbar('Error', msg,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(.9)));
  }

  static info({required String msg}) {
    print('[DEBUG] MyDialogs.info: msg="$msg"');
    _safeSnackbar(() => Get.snackbar('Info', msg, colorText: Colors.white));
  }

  static showProgress() {
    Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}
