import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isAppOpenAdReady = false;
  bool _isShowingAppOpenAd = false;
  bool _isShowingAnyAd = false; // Track if any ad is currently showing
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;
  int _appOpenLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  // iOS Production Ad Unit IDs - REPLACE THESE WITH YOUR REAL AD UNIT IDs
  static const String interstitialAdUnitId =
      'ca-app-pub-3945693141512838/5622013872'; // Your iOS interstitial
  static const String rewardedAdUnitId =
      'ca-app-pub-3945693141512838/5264304118'; // Your iOS rewarded
  static const String appOpenAdUnitId =
      'ca-app-pub-3945693141512838/1269218786'; // Your iOS app open

  // Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Load Interstitial Ad
  void loadInterstitialAd() {
    if (kDebugMode) {
      print('🔄 Loading Interstitial Ad...');
    }
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            print('✅ Interstitial Ad loaded successfully');
          }
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialLoadAttempts = 0;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (InterstitialAd ad) {
                  ad.dispose();
                  _isInterstitialAdReady = false;
                  loadInterstitialAd(); // Load next ad
                },
                onAdFailedToShowFullScreenContent:
                    (InterstitialAd ad, AdError error) {
                      ad.dispose();
                      _isInterstitialAdReady = false;
                      loadInterstitialAd(); // Load next ad
                    },
              );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('❌ Interstitial Ad failed to load: ${error.message}');
            print('   Code: ${error.code}, Domain: ${error.domain}');
          }
          _interstitialLoadAttempts += 1;
          _isInterstitialAdReady = false;
          if (_interstitialLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), () {
              loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  // Show Interstitial Ad
  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _isShowingAnyAd = true; // Mark that an ad is showing
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _isShowingAnyAd = false; // Ad closed
          onAdClosed?.call();
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _isShowingAnyAd = false; // Ad failed
          onAdClosed?.call();
          loadInterstitialAd(); // Load next ad
        },
      );
      await _interstitialAd!.show();
    } else {
      // If ad is not ready, just call the callback
      onAdClosed?.call();
      // Try to load ad for next time
      if (!_isInterstitialAdReady) {
        loadInterstitialAd();
      }
    }
  }

  // Load Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _rewardedLoadAttempts = 0;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedLoadAttempts += 1;
          _isRewardedAdReady = false;
          if (_rewardedLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), () {
              loadRewardedAd();
            });
          }
        },
      ),
    );
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd() async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      bool rewardEarned = false;
      _isShowingAnyAd = true; // Mark that an ad is showing

      // Create a completer to wait for the ad to finish
      final completer = Completer<bool>();

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _isRewardedAdReady = false;
          _isShowingAnyAd = false; // Ad closed
          loadRewardedAd(); // Load next ad
          if (!completer.isCompleted) {
            completer.complete(rewardEarned);
          }
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          _isRewardedAdReady = false;
          _isShowingAnyAd = false; // Ad failed
          loadRewardedAd(); // Load next ad
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          rewardEarned = true;
        },
      );

      // Wait for the ad to be dismissed before returning
      return await completer.future;
    } else {
      // If ad is not ready, don't allow action
      if (kDebugMode) {
        print('⚠️ Rewarded ad not ready');
      }
      if (!_isRewardedAdReady) {
        loadRewardedAd();
      }
      return false; // Don't allow action without watching ad
    }
  }

  // Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;

  // Load App Open Ad
  void loadAppOpenAd() {
    if (kDebugMode) {
      print('🔄 Loading App Open Ad...');
    }
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          if (kDebugMode) {
            print('✅ App Open Ad loaded successfully');
          }
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
          _appOpenLoadAttempts = 0;

          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (AppOpenAd ad) {
              if (kDebugMode) {
                print('❌ App Open Ad dismissed');
              }
              ad.dispose();
              _isAppOpenAdReady = false;
              _isShowingAppOpenAd = false;
              _isShowingAnyAd = false; // Clear flag when dismissed
              loadAppOpenAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
              if (kDebugMode) {
                print('⚠️ App Open Ad failed to show: ${error.message}');
              }
              ad.dispose();
              _isAppOpenAdReady = false;
              _isShowingAppOpenAd = false;
              _isShowingAnyAd = false; // Clear flag on failure
              loadAppOpenAd(); // Load next ad
            },
            onAdShowedFullScreenContent: (AppOpenAd ad) {
              if (kDebugMode) {
                print('📺 App Open Ad showing');
              }
              _isShowingAppOpenAd = true;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('❌ App Open Ad failed to load: ${error.message}');
          }
          _appOpenLoadAttempts += 1;
          _isAppOpenAdReady = false;
          if (_appOpenLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), () {
              loadAppOpenAd();
            });
          }
        },
      ),
    );
  }

  // Show App Open Ad
  Future<void> showAppOpenAd() async {
    // Don't show if already showing an app open ad
    if (_isShowingAppOpenAd) {
      if (kDebugMode) {
        print('⏭️ App Open Ad already showing, skipping');
      }
      return;
    }

    // Don't show if ANY other ad (interstitial/rewarded) is currently showing or was just shown
    if (_isShowingAnyAd) {
      if (kDebugMode) {
        print(
          '⏭️ Another ad is showing or was just shown, skipping App Open Ad',
        );
      }
      return;
    }

    if (_isAppOpenAdReady && _appOpenAd != null) {
      if (kDebugMode) {
        print('🎬 Showing App Open Ad');
      }
      _isShowingAnyAd = true; // Mark that we're showing an ad
      await _appOpenAd!.show();
    } else {
      if (kDebugMode) {
        print('⏳ App Open Ad not ready yet');
      }
      // Load ad for next time
      if (!_isAppOpenAdReady) {
        loadAppOpenAd();
      }
    }
  }

  // Check if app open ad is ready
  bool get isAppOpenAdReady => _isAppOpenAdReady && !_isShowingAppOpenAd;

  // Dispose ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
