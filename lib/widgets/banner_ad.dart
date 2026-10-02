import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      // Google test Banner Ad Unit ID, real - ca-app-pub-1144934871702370/6826236486
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',

      size: AdSize.banner,

      request: const AdRequest(),

      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;

          setState(() {
            _isLoaded = true;
          });
        },

        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad failed to load: $error');

          ad.dispose();

          if (!mounted) return;

          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(
        ad: _bannerAd!,
      ),
    );
  }
}
