import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class Config {
  static final _config = FirebaseRemoteConfig.instance;

  /// Set to true to use Google's sample ad units (safe for testing; no real revenue).
  /// When false and running in debug, test IDs are used automatically unless you override.
  static const bool useTestAds = kDebugMode;

  /// Google's sample ad unit IDs for testing (Android & iOS).
  /// See: https://developers.google.com/admob/android/test-ads
  static const String testInterstitialAd = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAd = 'ca-app-pub-3940256099942544/5224354917';
  static const String testNativeAd = 'ca-app-pub-3940256099942544/2247696110';

  static const _defaultValues = {
    "interstitial_ad": "ca-app-pub-5561438827097019/9789037444",
    "native_ad": "ca-app-pub-5561438827097019/8290438738",
    "rewarded_ad": "ca-app-pub-5561438827097019/6751810564",
    "show_ads": true
  };

  static Future<void> initConfig() async {
    await _config.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 30)));

    await _config.setDefaults(_defaultValues);
    await _config.fetchAndActivate();
    log('Remote Config Data: ${_config.getBool('show_ads')}');

    _config.onConfigUpdated.listen((event) async {
      await _config.activate();
      log('Updated: ${_config.getBool('show_ads')}');
    });
  }

  static bool get _showAd => _config.getBool('show_ads');

  static String get nativeAd =>
      useTestAds ? testNativeAd : _config.getString('native_ad');
  static String get interstitialAd =>
      useTestAds ? testInterstitialAd : _config.getString('interstitial_ad');
  static String get rewardedAd =>
      useTestAds ? testRewardedAd : _config.getString('rewarded_ad');

  static bool get hideAds => !_showAd;
}
