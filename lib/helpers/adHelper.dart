import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/config.dart' as config;

BannerAd adBanner = BannerAd(
  adUnitId: config.bannerUnitId,
  size: AdSize.smartBanner,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
    FirebaseAnalytics().logEvent(name: event.toString());
  },
);