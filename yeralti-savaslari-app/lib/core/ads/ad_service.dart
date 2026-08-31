import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // ⚠️ GERÇEK REKLAM BİRİMİ ID'LERİ
  // AdMob panelinden (admob.google.com) oluşturduğunuz birim ID'lerini buraya girebilirsiniz.
  // Boş bırakıldığında veya debug modda Google'ın resmi TEST ID'leri kullanılır.
  static const String _prodAndroidBannerId = '';
  static const String _prodAndroidInterstitialId = '';
  static const String _prodiOSBannerId = '';
  static const String _prodiOSInterstitialId = '';

  // Google Resmi Test Reklam ID'leri
  static const String _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testiOSBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testiOSInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return (kReleaseMode && _prodAndroidBannerId.isNotEmpty)
          ? _prodAndroidBannerId
          : _testAndroidBannerId;
    } else if (Platform.isIOS) {
      return (kReleaseMode && _prodiOSBannerId.isNotEmpty)
          ? _prodiOSBannerId
          : _testiOSBannerId;
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return (kReleaseMode && _prodAndroidInterstitialId.isNotEmpty)
          ? _prodAndroidInterstitialId
          : _testAndroidInterstitialId;
    } else if (Platform.isIOS) {
      return (kReleaseMode && _prodiOSInterstitialId.isNotEmpty)
          ? _prodiOSInterstitialId
          : _testiOSInterstitialId;
    }
    return '';
  }

  /// AdMob SDK Başlatma
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// Banner Reklam Oluşturucu
  BannerAd? createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    AdSize adSize = AdSize.banner,
  }) {
    if (!_isInitialized || bannerAdUnitId.isEmpty) return null;

    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );

    bannerAd.load();
    return bannerAd;
  }

  /// Geçiş (Interstitial) Reklamı Yükle
  void loadInterstitialAd() {
    if (!_isInitialized || _isInterstitialLoading || interstitialAdUnitId.isEmpty) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  /// Geçiş (Interstitial) Reklamı Göster
  void showInterstitialAd({VoidCallback? onDismissed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      loadInterstitialAd();
      onDismissed?.call();
    }
  }
}
