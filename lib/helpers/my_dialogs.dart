import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';

class MyDialogs {
  static success({required String msg}) {
    Get.snackbar('Success', msg,
        colorText: AppTheme.textPrimary,
        backgroundColor: AppTheme.connectedGreen.withOpacity(.9));
  }

  static error({required String msg}) {
    Get.snackbar('Error', msg,
        colorText: AppTheme.textPrimary,
        backgroundColor: AppTheme.connectingOrange.withOpacity(.9));
  }

  static info({required String msg}) {
    Get.snackbar('Info', msg, colorText: AppTheme.textPrimary);
  }

  static showProgress() {
    Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}
