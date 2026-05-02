import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../controllers/native_ad_controller.dart';
import 'config.dart';
import 'my_dialogs.dart';

class AdHelper {
  static const Duration _rewardedRetryDelay = Duration(milliseconds: 1200);

  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;

  static RewardedAd? _rewardedAd;
  static bool _rewardedAdLoaded = false;
  static int _rewardedLoadSession = 0;

  static void precacheInterstitialAd() {
    if (Config.hideAds) return;
    final ids = Config.interstitialAdIds;
    if (ids.isEmpty) return;
    _tryPrecacheInterstitialAd(ids, 0);
  }

  static void _tryPrecacheInterstitialAd(List<String> ids, int index) {
    if (index >= ids.length) {
      log('All interstitial ad IDs failed to load');
      return;
    }
    final adUnitId = ids[index];
    log('Precache Interstitial Ad - Id: $adUnitId (${index + 1}/${ids.length})');
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          log('Failed to load interstitial ad: ${err.message}, trying next ID...');
          _tryPrecacheInterstitialAd(ids, index + 1);
        },
      ),
    );
  }

  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  static void showInterstitialAd({required VoidCallback onComplete}) {
    if (Config.hideAds) {
      onComplete();
      return;
    }

    final ids = Config.interstitialAdIds;
    if (ids.isEmpty) {
      onComplete();
      return;
    }

    if (_interstitialAdLoaded && _interstitialAd != null) {
      final ad = _interstitialAd!;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          onComplete();
          _resetInterstitialAd();
          precacheInterstitialAd();
        },
      );
      ad.show();
      return;
    }

    MyDialogs.showProgress();
    _tryShowInterstitialAd(ids, 0, onComplete);
  }

  static void _tryShowInterstitialAd(
    List<String> ids,
    int index,
    VoidCallback onComplete,
  ) {
    if (index >= ids.length) {
      Get.back();
      log('All interstitial ad IDs failed to load');
      onComplete();
      return;
    }
    final adUnitId = ids[index];
    log('Interstitial Ad Id: $adUnitId (${index + 1}/${ids.length})');
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              onComplete();
              _resetInterstitialAd();
              precacheInterstitialAd();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (err) {
          log('Failed to load interstitial ad: ${err.message}, trying next ID...');
          _tryShowInterstitialAd(ids, index + 1, onComplete);
        },
      ),
    );
  }

  static void precacheNativeAd() {
    if (Config.hideAds) return;
    final ids = Config.nativeAdIds;
    if (ids.isEmpty) return;
    _tryPrecacheNativeAd(ids, 0);
  }

  static void _tryPrecacheNativeAd(List<String> ids, int index) {
    if (index >= ids.length) {
      log('All native ad IDs failed to load');
      return;
    }
    final adUnitId = ids[index];
    log('Precache Native Ad - Id: $adUnitId (${index + 1}/${ids.length})');
    _nativeAd = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _nativeAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd();
            log('NativeAd failed to load: $error, trying next ID...');
            _tryPrecacheNativeAd(ids, index + 1);
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small))
      ..load();
  }

  static void _resetNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
  }

  static NativeAd? loadNativeAd({required NativeAdController adController}) {
    if (Config.hideAds) return null;

    final ids = Config.nativeAdIds;
    if (ids.isEmpty) return null;

    if (_nativeAdLoaded && _nativeAd != null) {
      final ad = _nativeAd!;
      _nativeAd = null;
      _nativeAdLoaded = false;
      adController.ad = ad;
      adController.adLoaded.value = true;
      precacheNativeAd();
      return ad;
    }

    _tryLoadNativeAd(ids, 0, adController);
    return null;
  }

  static void _tryLoadNativeAd(
    List<String> ids,
    int index,
    NativeAdController adController,
  ) {
    if (index >= ids.length) {
      log('All native ad IDs failed to load');
      return;
    }
    final adUnitId = ids[index];
    log('Native Ad Id: $adUnitId (${index + 1}/${ids.length})');
    final ad = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.ad = ad as NativeAd;
            adController.adLoaded.value = true;
            _resetNativeAd();
            precacheNativeAd();
          },
          onAdFailedToLoad: (ad, error) {
            adController.ad?.dispose();
            adController.ad = null;
            adController.adLoaded.value = false;
            log('NativeAd failed to load: $error, trying next ID...');
            _tryLoadNativeAd(ids, index + 1, adController);
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small));
    adController.ad = ad;
    ad.load();
  }

  static void precacheRewardedAd() {
    if (Config.hideAds) return;
    if (_rewardedAdLoaded && _rewardedAd != null) return;
    final ids =
        Config.rewardedAdIds.where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) return;
    _precacheRewardedAdFirstSuccess(ids);
  }

  static void _precacheRewardedAdFirstSuccess(List<String> ids) {
    final session = ++_rewardedLoadSession;
    var firstAdResolved = false;
    var failureCount = 0;

    for (var i = 0; i < ids.length; i++) {
      final adUnitId = ids[i];
      log('Precache Rewarded Ad - Id: $adUnitId (${i + 1}/${ids.length})');
      RewardedAd.load(
        adUnitId: adUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (session != _rewardedLoadSession) {
              ad.dispose();
              return;
            }

            if (!firstAdResolved) {
              firstAdResolved = true;
              _resetRewardedAd();
              _rewardedAd = ad;
              _rewardedAdLoaded = true;
              log('RewardedAd precache success with first available ID.');
              return;
            }

            ad.dispose();
          },
          onAdFailedToLoad: (err) {
            if (session != _rewardedLoadSession) return;
            failureCount++;
            log('Failed to load rewarded ad: ${err.message}');
            if (failureCount >= ids.length && !firstAdResolved) {
              _resetRewardedAd();
              log('All rewarded ad IDs failed to load');
            }
          },
        ),
      );
    }
  }

  static void _resetRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _rewardedAdLoaded = false;
  }

  static void showRewardedAd({
    required VoidCallback onComplete,
    VoidCallback? onSkipped,
    Duration minimumWatchDuration = const Duration(seconds: 45),
  }) {
    if (Config.hideAds) {
      onComplete();
      return;
    }

    final ids =
        Config.rewardedAdIds.where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) {
      onSkipped?.call();
      return;
    }

    if (_rewardedAdLoaded && _rewardedAd != null) {
      final ad = _rewardedAd!;
      _rewardedAd = null;
      _rewardedAdLoaded = false;
      _showRewardedAdWithMandatoryWatch(
        ids: ids,
        ad: ad,
        onComplete: onComplete,
        onSkipped: onSkipped,
        minimumWatchDuration: minimumWatchDuration,
      );
      return;
    }

    MyDialogs.showProgress();
    _loadAndShowRewardedAdUntilShown(
      ids: ids,
      session: ++_rewardedLoadSession,
      onComplete: onComplete,
      onSkipped: onSkipped,
      minimumWatchDuration: minimumWatchDuration,
    );
  }

  static void _loadAndShowRewardedAdUntilShown({
    required List<String> ids,
    required int session,
    int index = 0,
    int attempt = 1,
    required VoidCallback onComplete,
    required VoidCallback? onSkipped,
    required Duration minimumWatchDuration,
  }) {
    if (session != _rewardedLoadSession || ids.isEmpty || Config.hideAds) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      onSkipped?.call();
      return;
    }

    final adUnitId = ids[index];
    log('Rewarded Ad retry #$attempt with Id: $adUnitId (${index + 1}/${ids.length})');
    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (session != _rewardedLoadSession) {
            ad.dispose();
            return;
          }

          if (Get.isDialogOpen == true) {
            Get.back();
          }

          _showRewardedAdWithMandatoryWatch(
            ids: ids,
            ad: ad,
            onComplete: onComplete,
            onSkipped: onSkipped,
            minimumWatchDuration: minimumWatchDuration,
          );
        },
        onAdFailedToLoad: (err) {
          if (session != _rewardedLoadSession) return;
          log('Failed to load rewarded ad: ${err.message}');

          final nextIndex = (index + 1) % ids.length;
          final nextAttempt = attempt + 1;
          final delay = nextIndex == 0 ? _rewardedRetryDelay : Duration.zero;

          if (nextIndex == 0) {
            log('All rewarded IDs failed in this round. Retrying...');
          }

          Future.delayed(delay, () {
            _loadAndShowRewardedAdUntilShown(
              ids: ids,
              session: session,
              index: nextIndex,
              attempt: nextAttempt,
              onComplete: onComplete,
              onSkipped: onSkipped,
              minimumWatchDuration: minimumWatchDuration,
            );
          });
        },
      ),
    );
  }

  static void _showRewardedAdWithMandatoryWatch({
    required List<String> ids,
    required RewardedAd ad,
    required VoidCallback onComplete,
    required VoidCallback? onSkipped,
    required Duration minimumWatchDuration,
  }) {
    final shownAt = DateTime.now();
    var rewardEarned = false;
    var handled = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        precacheRewardedAd();

        if (handled) return;
        handled = true;

        final watchedLongEnough =
            DateTime.now().difference(shownAt) >= minimumWatchDuration;
        if (rewardEarned && watchedLongEnough) {
          onComplete();
        } else {
          onSkipped?.call();
        }
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        _resetRewardedAd();
        if (handled) return;
        handled = true;
        log('Rewarded ad failed to show: ${error.message}');
        MyDialogs.showProgress();
        _loadAndShowRewardedAdUntilShown(
          ids: ids,
          session: ++_rewardedLoadSession,
          onComplete: onComplete,
          onSkipped: onSkipped,
          minimumWatchDuration: minimumWatchDuration,
        );
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      rewardEarned = true;
    });
  }
}
