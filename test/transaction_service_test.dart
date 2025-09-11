import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickbudged/models/transaction.dart';
import 'package:quickbudged/services/transaction_service.dart';
import 'package:quickbudged/utils/constants.dart';

void main() {
  late TransactionService transactionService;

  setUp(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());

    // Create service instance
    transactionService = TransactionService();
    await transactionService.init();
  });

  tearDown(() async {
    // Clean up after each test
    await transactionService.clearAllTransactions();
    await transactionService.close();
  });

  test('Add and retrieve transaction', () async {
    // Create a test transaction
    final transaction = Transaction(
      id: 'test-1',
      description: 'Test transaction',
      amount: 50.0,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      date: DateTime.now(),
      currency: 'BRL',
    );

    // Add transaction
    await transactionService.addTransaction(transaction);

    // Retrieve transaction
    final retrieved = transactionService.getTransactionById('test-1');

    // Verify
    expect(retrieved, isNotNull);
    expect(retrieved!.description, equals('Test transaction'));
    expect(retrieved.amount, equals(50.0));
    expect(retrieved.type, equals(TransactionType.expense));
    expect(retrieved.category, equals(TransactionCategory.groceries));
  });

  test('Calculate balance correctly', () async {
    // Add income transaction
    final income = Transaction(
      id: 'income-1',
      description: 'Salary',
      amount: 3000.0,
      type: TransactionType.income,
      category: TransactionCategory.other,
      date: DateTime.now(),
      currency: 'BRL',
    );

    // Add expense transaction
    final expense = Transaction(
      id: 'expense-1',
      description: 'Groceries',
      amount: 500.0,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      date: DateTime.now(),
      currency: 'BRL',
    );

    await transactionService.addTransaction(income);
    await transactionService.addTransaction(expense);

    // Check calculations
    expect(transactionService.getTotalIncome(), equals(3000.0));
    expect(transactionService.getTotalExpenses(), equals(500.0));
    expect(transactionService.getBalance(), equals(2500.0));
  });

  test('Filter transactions by type', () async {
    // Add multiple transactions
    final income = Transaction(
      id: 'income-1',
      description: 'Salary',
      amount: 3000.0,
      type: TransactionType.income,
      category: TransactionCategory.other,
      date: DateTime.now(),
      currency: 'BRL',
    );

    final expense1 = Transaction(
      id: 'expense-1',
      description: 'Groceries',
      amount: 500.0,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
      date: DateTime.now(),
      currency: 'BRL',
    );

    final expense2 = Transaction(
      id: 'expense-2',
      description: 'Transport',
      amount: 200.0,
      type: TransactionType.expense,
      category: TransactionCategory.transportation,
      date: DateTime.now(),
      currency: 'BRL',
    );

    await transactionService.addTransaction(income);
    await transactionService.addTransaction(expense1);
    await transactionService.addTransaction(expense2);

    // Test filtering
    final incomes = transactionService.getTransactionsByType(
      TransactionType.income,
    );
    final expenses = transactionService.getTransactionsByType(
      TransactionType.expense,
    );

    expect(incomes.length, equals(1));
    expect(expenses.length, equals(2));
    expect(transactionService.getTransactionCount(), equals(3));
  });

  test('Free plan limit check', () async {
    // Add transactions up to the limit
    for (int i = 0; i < AppConstants.freePlanLimit; i++) {
      final transaction = Transaction(
        id: 'test-$i',
        description: 'Test $i',
        amount: 10.0,
        type: TransactionType.expense,
        category: TransactionCategory.other,
        date: DateTime.now(),
        currency: 'BRL',
      );
      await transactionService.addTransaction(transaction);
    }

    // Check if limit is reached
    expect(transactionService.hasReachedFreeLimit(), isTrue);
    expect(
      transactionService.getTransactionCount(),
      equals(AppConstants.freePlanLimit),
    );
  });
}
