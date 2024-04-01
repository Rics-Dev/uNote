
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  Future<InitializationStatus> initialization;

  AdProvider(this.initialization);

final String bannerAdUnitId = 'ca-app-pub-5759628853965182/8869315438';
    // Use this ad unit on Android...


  
  // Listener get adListener => _adListener

  // final AdService _adService = AdService();
  // final List<Ad> _ads = [];
  // List<Ad> get ads => _ads;

  // Future<void> fetchAds() async {
  //   _ads.clear();
  //   _ads.addAll(await _adService.fetchAds());
  //   notifyListeners();
  // }
}
