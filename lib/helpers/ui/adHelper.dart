import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/config.dart' as config;

//TODO: Refresh my admob settings https://codelabs.developers.google.com/codelabs/admob-ads-in-flutter#0
BannerAd adBanner = BannerAd(
  adUnitId: config.bannerUnitId,
  size: AdSize.smartBanner,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
    if (event == MobileAdEvent.failedToLoad)
      FirebaseAnalytics().logEvent(name: "AdFailed");
  },
);
