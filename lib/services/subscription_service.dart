import 'package:hive/hive.dart';
import '../models/transaction.dart';

class SubscriptionService {
  static const String _premiumBoxKey = 'premium_status';
  static const String _transactionCountKey = 'transaction_count';
  static const int _freeTransactionLimit = 10;

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('subscription');
  }

  // Check if user has premium
  bool get isPremium => _box.get(_premiumBoxKey, defaultValue: false);

  // Set premium status
  Future<void> setPremium(bool premium) async {
    await _box.put(_premiumBoxKey, premium);
  }

  // Get current transaction count
  int get transactionCount => _box.get(_transactionCountKey, defaultValue: 0);

  // Increment transaction count
  Future<void> incrementTransactionCount() async {
    final currentCount = transactionCount;
    await _box.put(_transactionCountKey, currentCount + 1);
  }

  // Reset transaction count (for testing or premium upgrade)
  Future<void> resetTransactionCount() async {
    await _box.put(_transactionCountKey, 0);
  }

  // Check if user can add more transactions
  bool canAddTransaction() {
    return isPremium || transactionCount < _freeTransactionLimit;
  }

  // Get remaining free transactions
  int get remainingFreeTransactions {
    if (isPremium) return -1; // Unlimited
    return _freeTransactionLimit - transactionCount;
  }

  // Check if user should see upgrade prompt
  bool shouldShowUpgradePrompt() {
    return !isPremium && transactionCount >= _freeTransactionLimit;
  }

  // Get upgrade message based on current state
  String getUpgradeMessage() {
    if (isPremium) {
      return 'Você tem acesso ilimitado ao Premium!';
    }

    final remaining = remainingFreeTransactions;
    if (remaining > 0) {
      return 'Você tem $remaining lançamentos gratuitos restantes.';
    } else {
      return 'Você atingiu 10 lançamentos no plano Free. Desbloqueie ilimitado + PDF + sem anúncios com o Premium!';
    }
  }

  // Handle transaction addition with limit checking
  Future<bool> tryAddTransaction(Transaction transaction) async {
    if (!canAddTransaction()) {
      return false; // Cannot add transaction
    }

    if (!isPremium) {
      await incrementTransactionCount();
    }

    return true; // Transaction can be added
  }

  // Get premium features status
  Map<String, bool> getPremiumFeatures() {
    return {
      'unlimited_transactions': isPremium,
      'pdf_export': isPremium,
      'no_ads': isPremium,
      'charts': true, // Charts are available for all users
      'voice_input': true, // Voice input is available for all users
    };
  }

  // Simulate premium purchase (for testing)
  Future<void> simulatePremiumPurchase() async {
    await setPremium(true);
    await resetTransactionCount();
  }

  // Simulate downgrade to free (for testing)
  Future<void> simulateFreeDowngrade() async {
    await setPremium(false);
    // Keep transaction count as is
  }
}
