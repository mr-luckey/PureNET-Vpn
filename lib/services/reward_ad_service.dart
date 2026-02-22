import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/config.dart';

/// Reward Ad Service - Shows rewarded ads with minimum 30 second watch time.
/// On reward completion, the user can connect to the VPN server.
class RewardAdService {
  static final RewardAdService _instance = RewardAdService._internal();
  factory RewardAdService() => _instance;
  RewardAdService._internal();

  static RewardedAd? _currentAd;
  static bool _isAdLoading = false;
  static int _currentAdIndex = 0;
  static const int _minWatchDurationSeconds = 30;

  List<String> get _adUnitIds => [
        Config.rewardedAd,
        'ca-app-pub-5561438827097019/1405850191',
        'ca-app-pub-5561438827097019/4530018623',
        'ca-app-pub-5561438827097019/5369145933',
        'ca-app-pub-5561438827097019/6546496236',
        'ca-app-pub-5561438827097019/4056064261',
        // 'ca-app-pub-5561438827097019/6658176879',
        // 'ca-app-pub-5561438827097019/7312782994',
        // 'ca-app-pub-5561438827097019/7065370980',
        // 'ca-app-pub-5561438827097019/4686619655',
        // 'ca-app-pub-5561438827097019/3373537989',
        // 'ca-app-pub-5561438827097019/9420071589',
        // 'ca-app-pub-5561438827097019/2286998664',

        // 'ca-app-pub-5561438827097019/9820910070',
        // 'ca-app-pub-5561438827097019/2133991744',
        // 'ca-app-pub-5561438827097019/7138906414',
      ];

  DateTime? _adShownAt;

  void initialize() {
    if (Config.hideAds) return;
    _loadNextAd();
  }

  void _loadNextAd() {
    if (_isAdLoading) return;
    _isAdLoading = true;

    debugPrint('Loading rewarded ad with ID: ${_adUnitIds[_currentAdIndex]}');

    RewardedAd.load(
      adUnitId: _adUnitIds[_currentAdIndex],
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('Rewarded ad loaded successfully');
          _currentAd = ad;
          _isAdLoading = false;
          _setupAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Rewarded ad failed to load: ${error.message}');
          _isAdLoading = false;
          _tryNextAd();
        },
      ),
    );
  }

  void _setupAdCallbacks() {
    _currentAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _currentAd = null;
        _tryNextAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _currentAd = null;
        _tryNextAd();
      },
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad showed - timer started');
        _adShownAt = DateTime.now();
      },
    );
  }

  void _tryNextAd() {
    _currentAdIndex = (_currentAdIndex + 1) % _adUnitIds.length;
    _loadNextAd();
  }

  bool isAdReady() {
    return _currentAd != null;
  }

  /// Waits for ad to be ready (loads if needed). Returns true when ready, false on timeout.
  Future<bool> waitForAdReady({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (Config.hideAds) return false;
    if (_currentAd != null) return true;
    if (!_isAdLoading) _loadNextAd();

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_currentAd != null) return true;
    }
    return false;
  }

  /// Shows the reward ad. When user completes the ad (watches minimum 30 seconds),
  /// [onRewardGranted] is called and the user can connect to the server.
  /// If ad fails to load or show, [onAdNotAvailable] is called - you may allow
  /// connection or show an error based on your logic.
  void showAd({
    required VoidCallback onRewardGranted,
    VoidCallback? onAdNotAvailable,
  }) {
    if (Config.hideAds) {
      onRewardGranted();
      return;
    }
    if (_currentAd != null) {
      _adShownAt = null;

      _currentAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          final now = DateTime.now();
          final elapsedSeconds = _adShownAt != null
              ? now.difference(_adShownAt!).inSeconds
              : _minWatchDurationSeconds;

          if (elapsedSeconds >= _minWatchDurationSeconds) {
            debugPrint(
                'Reward granted after $elapsedSeconds seconds (min: $_minWatchDurationSeconds)');
            onRewardGranted();
          } else {
            final remaining = _minWatchDurationSeconds - elapsedSeconds;
            debugPrint(
                'Ad finished early. Waiting $remaining more seconds for minimum 30s...');
            Future.delayed(Duration(seconds: remaining), () {
              onRewardGranted();
            });
          }
        },
      );
    } else {
      debugPrint('No rewarded ad available to show');
      onAdNotAvailable?.call();
      _loadNextAd();
    }
  }

  void dispose() {
    _currentAd?.dispose();
    _currentAd = null;
  }
}
