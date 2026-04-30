import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Cycles through multiple interstitial ad units and auto-shows them.
class AdManager {
  AdManager._internal();

  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  static InterstitialAd? _currentAd;
  static bool _isAdLoading = false;
  static int _currentAdIndex = 0;
  static Timer? _adTimer;
  static bool _isAdShown = false;
  static DateTime? _lastAdShownTime;

  /// Rotates 20 interstitial IDs; keep synced with AdMob console.
  static final List<String> _adUnitIds = [
    'ca-app-pub-5561438827097019/1888997432',
    'ca-app-pub-5561438827097019/5133397430',
    'ca-app-pub-5561438827097019/3086529034',
    'ca-app-pub-5561438827097019/1989177583',
    'ca-app-pub-5561438827097019/3660533661',
    'ca-app-pub-5561438827097019/6458797833',
    'ca-app-pub-5561438827097019/8363014247',
    'ca-app-pub-5561438827097019/6949752428',
    'ca-app-pub-5561438827097019/5636670755',
    'ca-app-pub-5561438827097019/4323589084',
    'ca-app-pub-5561438827097019/4270907753',
    'ca-app-pub-5561438827097019/2957826085',
    'ca-app-pub-5561438827097019/3820315762',
    'ca-app-pub-5561438827097019/3105999894',
    'ca-app-pub-5561438827097019/3848946368'
  ];

  void initialize() {
    _startAdTimer();
    _loadNextAd();
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkAndLoadAd();
    });
  }

  void _checkAndLoadAd() {
    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      if (timeSinceLastAd.inSeconds < 10) {
        return; // Enforce ~10s gap between interstitials.
      }
    }

    if (!_isAdShown && _currentAd != null) {
      _showAd();
    } else if (!_isAdShown && !_isAdLoading) {
      _loadNextAd();
    }
  }

  void _loadNextAd() {
    if (_isAdLoading) return;

    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: _adUnitIds[_currentAdIndex],
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _currentAd = ad;
          _isAdLoading = false;
          _setupAdCallbacks();
          _showAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoading = false;
          _tryNextAd();
        },
      ),
    );
  }

  void _setupAdCallbacks() {
    _currentAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _currentAd = null;
        _isAdShown = false;
        _lastAdShownTime = DateTime.now();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _currentAd = null;
        _isAdShown = false;
        _tryNextAd();
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _isAdShown = true;
        _lastAdShownTime = DateTime.now();
      },
    );
  }

  void _tryNextAd() {
    _currentAdIndex = (_currentAdIndex + 1) % _adUnitIds.length;
    _loadNextAd();
  }

  void _showAd() {
    if (_currentAd != null && !_isAdShown) {
      _currentAd?.show();
    }
  }

  void dispose() {
    _adTimer?.cancel();
    _currentAd?.dispose();
    _currentAd = null;
  }
}
