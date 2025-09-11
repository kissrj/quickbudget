import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final TransactionCategory category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String currency;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.currency,
  });

  // Factory constructor for creating from voice input
  factory Transaction.fromVoiceInput({
    required String description,
    required double amount,
    required TransactionCategory category,
    required String currency,
  }) {
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      type: _getTransactionTypeFromCategory(category),
      category: category,
      date: DateTime.now(),
      currency: currency,
    );
  }

  // Helper method to determine transaction type from category
  static TransactionType _getTransactionTypeFromCategory(
    TransactionCategory category,
  ) {
    // Expense categories
    if (category == TransactionCategory.groceries ||
        category == TransactionCategory.transportation ||
        category == TransactionCategory.housing ||
        category == TransactionCategory.entertainment ||
        category == TransactionCategory.health ||
        category == TransactionCategory.food ||
        category == TransactionCategory.utilities ||
        category == TransactionCategory.shopping ||
        category == TransactionCategory.education ||
        category == TransactionCategory.personal) {
      return TransactionType.expense;
    }

    // Income categories
    if (category == TransactionCategory.salary ||
        category == TransactionCategory.freelance ||
        category == TransactionCategory.investments ||
        category == TransactionCategory.rental ||
        category == TransactionCategory.business ||
        category == TransactionCategory.gifts) {
      return TransactionType.income;
    }

    // Default to expense for 'other'
    return TransactionType.expense;
  }

  // Copy with method for updates
  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? currency,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      currency: currency ?? this.currency,
    );
  }

  // Get category display name
  String get categoryDisplayName {
    switch (category) {
      // Expense categories
      case TransactionCategory.groceries:
        return 'Mercado';
      case TransactionCategory.transportation:
        return 'Transporte';
      case TransactionCategory.housing:
        return 'Moradia';
      case TransactionCategory.entertainment:
        return 'Lazer';
      case TransactionCategory.health:
        return 'Saúde';
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.utilities:
        return 'Utilidades';
      case TransactionCategory.shopping:
        return 'Compras';
      case TransactionCategory.education:
        return 'Educação';
      case TransactionCategory.personal:
        return 'Pessoal';

      // Income categories
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investments:
        return 'Investimentos';
      case TransactionCategory.rental:
        return 'Aluguel';
      case TransactionCategory.business:
        return 'Negócios';
      case TransactionCategory.gifts:
        return 'Presentes';
      case TransactionCategory.other:
        return 'Outros';
    }
  }

  // Get type display name
  String get typeDisplayName {
    return type == TransactionType.income ? 'Receita' : 'Despesa';
  }

  // Formatted amount with currency (always positive)
  String get formattedAmount {
    final symbol = currency == 'BRL'
        ? 'R\$'
        : currency == 'USD'
        ? '\$'
        : '€';
    return '$symbol${amount.abs().toStringAsFixed(2)}';
  }

  // Formatted amount with sign for calculations
  String get formattedAmountWithSign {
    final symbol = currency == 'BRL'
        ? 'R\$'
        : currency == 'USD'
        ? '\$'
        : '€';
    final sign = type == TransactionType.expense ? '-' : '+';
    return '$sign$symbol${amount.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, type: $type, category: $category, date: $date, currency: $currency)';
  }
}
