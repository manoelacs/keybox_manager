/* import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  static final AdsManager _instance = AdsManager._internal();

  factory AdsManager() {
    return _instance;
  }

  AdsManager._internal();

  void initialize() {
    MobileAds.instance.initialize();
  }

  BannerAd createBannerAd(
      [String bannerAdUnitId = 'DEFAULT_BANNER_AD_UNIT_ID']) {
    return BannerAd(
      adUnitId: 'YOUR_BANNER_AD_UNIT_ID',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  InterstitialAd? interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'YOUR_INTERSTITIAL_AD_UNIT_ID',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
    }
  }
}
 */