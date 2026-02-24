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
  static const String testInterstitialAd =
      'ca-app-pub-5561438827097019/2225776147';
  static const String testRewardedAd = 'ca-app-pub-5561438827097019/9721122784';
  static const String testNativeAd = 'ca-app-pub-5561438827097019/4064278486';

  // ---------------------------------------------------------------------------
  // Separate ID list for each ad type (tried in order until one loads).
  // Add more IDs to any list for fallback.
  // ---------------------------------------------------------------------------

  /// Interstitial ad unit IDs.
  static const List<String> interstitialAdIdList = [
    'ca-app-pub-5561438827097019/6690441826',
    'ca-app-pub-5561438827097019/5861768829',
    'ca-app-pub-5561438827097019/1190703135',
    '',
  ];

  /// Native advanced ad unit IDs.
  static const List<String> nativeAdIdList = [
    'ca-app-pub-5561438827097019/8759394906',
    'ca-app-pub-5561438827097019/9125033476',
  ];

  /// Rewarded ad unit IDs.
  static const List<String> rewardedAdIdList = [
    'ca-app-pub-5561438827097019/3507068223',
    'ca-app-pub-5561438827097019/8408041115',
  ];

  static const _defaultValues = {
    "show_ads": true,
  };

  /// List of interstitial ad unit IDs; ads are tried in order until one loads.
  static List<String> get interstitialAdIds =>
      useTestAds ? [testInterstitialAd] : List.from(interstitialAdIdList);

  /// List of native ad unit IDs; ads are tried in order until one loads.
  static List<String> get nativeAdIds =>
      useTestAds ? [testNativeAd] : List.from(nativeAdIdList);

  /// List of rewarded ad unit IDs; ads are tried in order until one loads.
  static List<String> get rewardedAdIds =>
      useTestAds ? [testRewardedAd] : List.from(rewardedAdIdList);

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

  static bool get hideAds => !_showAd;
}
