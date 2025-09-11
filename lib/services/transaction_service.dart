import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'subscription_service.dart';

class TransactionService {
  static const String _boxName = 'transactions';
  late Box<Transaction> _transactionBox;
  final SubscriptionService _subscriptionService;

  TransactionService(this._subscriptionService);

  Future<void> init() async {
    _transactionBox = await Hive.openBox<Transaction>(_boxName);
  }

  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    // Check if user can add transaction (for free users)
    if (!_subscriptionService.canAddTransaction()) {
      throw Exception(
        'Limite do plano gratuito atingido. Faça upgrade para Premium.',
      );
    }

    await _transactionBox.put(transaction.id, transaction);

    // Increment transaction count for free users
    if (!_subscriptionService.isPremium) {
      await _subscriptionService.incrementTransactionCount();
    }
  }

  // Get all transactions
  List<Transaction> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactionBox.values
        .where((transaction) => transaction.type == type)
        .toList();
  }

  // Get transactions by category
  List<Transaction> getTransactionsByCategory(TransactionCategory category) {
    return _transactionBox.values
        .where((transaction) => transaction.category == category)
        .toList();
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.date.isAfter(
                start.subtract(const Duration(days: 1)),
              ) &&
              transaction.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get transactions for current month
  List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  // Update a transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  // Get transaction by ID
  Transaction? getTransactionById(String id) {
    return _transactionBox.get(id);
  }

  // Calculate total income
  double getTotalIncome() {
    return _transactionBox.values
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Calculate total expenses
  double getTotalExpenses() {
    return _transactionBox.values
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Calculate balance
  double getBalance() {
    return getTotalIncome() - getTotalExpenses();
  }

  // Get transaction count
  int getTransactionCount() {
    return _transactionBox.length;
  }

  // Check if user has reached free plan limit
  bool hasReachedFreeLimit() {
    return getTransactionCount() >= AppConstants.freePlanLimit;
  }

  // Get expenses by category for charts
  Map<TransactionCategory, double> getExpensesByCategory() {
    final expenses = _transactionBox.values.where(
      (transaction) => transaction.type == TransactionType.expense,
    );

    final Map<TransactionCategory, double> categoryTotals = {};

    for (final transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  // Search transactions by description
  List<Transaction> searchTransactions(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Clear all transactions (for testing)
  Future<void> clearAllTransactions() async {
    await _transactionBox.clear();
  }

  // Close the box
  Future<void> close() async {
    await _transactionBox.close();
  }
}
