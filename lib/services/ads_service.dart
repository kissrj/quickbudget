import 'package:flutter/material.dart';
import 'subscription_service.dart';

class AdsService {
  final SubscriptionService _subscriptionService;

  AdsService(this._subscriptionService);

  // Initialize ads (mock implementation)
  Future<void> init() async {
    print('Ads service initialized (mock)');
  }

  // Get banner ad widget (mock implementation)
  Widget? getBannerAdWidget() {
    if (!_subscriptionService.isPremium) {
      return Container(
        height: 50,
        color: Colors.grey[300],
        child: const Center(
          child: Text(
            'Ad Space - Upgrade to Premium to remove ads',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }
    return null;
  }

  // Show interstitial ad (mock implementation)
  Future<void> showInterstitialAd() async {
    if (!_subscriptionService.isPremium) {
      print('Showing interstitial ad (mock)');
      // In real implementation, this would show an actual ad
    }
  }

  // Show ad after transaction (for free users)
  Future<void> showAdAfterTransaction() async {
    if (!_subscriptionService.isPremium) {
      // Show mock ad every 3 transactions
      final transactionCount = _subscriptionService.transactionCount;
      if (transactionCount > 0 && transactionCount % 3 == 0) {
        print('Mock ad shown after transaction $transactionCount');
      }
    }
  }

  // Dispose ads (mock implementation)
  void dispose() {
    print('Ads service disposed (mock)');
  }

  // Check if ads should be shown
  bool shouldShowAds() {
    return !_subscriptionService.isPremium;
  }

  // Get ad status
  Map<String, dynamic> getAdStatus() {
    return {
      'banner_loaded': true, // Mock always loaded
      'interstitial_loaded': true, // Mock always loaded
      'ads_enabled': shouldShowAds(),
    };
  }
}
