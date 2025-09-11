import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class ChartsService {
  // Generate pie chart data for expense categories
  static List<PieChartSectionData> generateExpensePieChart(
    List<Transaction> transactions,
  ) {
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenseTransactions.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Sem\ndespesas',
          color: AppConstants.lightGray,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
      ];
    }

    // Group transactions by category
    final categoryTotals = <TransactionCategory, double>{};
    for (final transaction in expenseTransactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // Sort by amount (descending)
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 6 categories, group others as "Outros"
    const maxCategories = 6;
    final topCategories = sortedCategories.take(maxCategories).toList();
    final otherCategories = sortedCategories.skip(maxCategories).toList();

    final sections = <PieChartSectionData>[];

    // Add top categories
    for (int i = 0; i < topCategories.length; i++) {
      final entry = topCategories[i];
      final percentage =
          (entry.value / _getTotalExpenses(expenseTransactions)) * 100;

      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          color: _getCategoryColor(entry.key),
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppConstants.whiteColor,
          ),
        ),
      );
    }

    // Add "Outros" if there are more categories
    if (otherCategories.isNotEmpty) {
      final otherTotal = otherCategories.fold(
        0.0,
        (sum, entry) => sum + entry.value,
      );
      final percentage =
          (otherTotal / _getTotalExpenses(expenseTransactions)) * 100;

      sections.add(
        PieChartSectionData(
          value: otherTotal,
          title: '${percentage.toStringAsFixed(1)}%',
          color: AppConstants.lightGray,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
      );
    }

    return sections;
  }

  // Generate bar chart data for monthly evolution (last 6 months)
  static List<BarChartGroupData> generateMonthlyBarChart(
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final monthlyData = <int, Map<String, double>>{};

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = month.month + month.year * 12;
      monthlyData[monthKey] = {'income': 0, 'expenses': 0};
    }

    // Aggregate transactions by month
    for (final transaction in transactions) {
      final monthKey = transaction.date.month + transaction.date.year * 12;
      if (monthlyData.containsKey(monthKey)) {
        if (transaction.type == TransactionType.income) {
          monthlyData[monthKey]!['income'] =
              (monthlyData[monthKey]!['income'] ?? 0) + transaction.amount;
        } else {
          monthlyData[monthKey]!['expenses'] =
              (monthlyData[monthKey]!['expenses'] ?? 0) + transaction.amount;
        }
      }
    }

    // Convert to bar chart data
    final sortedMonths = monthlyData.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < sortedMonths.length; i++) {
      final monthKey = sortedMonths[i];
      final data = monthlyData[monthKey]!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data['income'] ?? 0,
              color: AppConstants.positiveColor,
              width: 16,
            ),
            BarChartRodData(
              toY: -(data['expenses'] ?? 0), // Negative for expenses
              color: AppConstants.expenseColor,
              width: 16,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  // Get month labels for bar chart
  static List<String> getMonthLabels() {
    final now = DateTime.now();
    final labels = <String>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = _getMonthName(month.month);
      labels.add(
        '${monthName.substring(0, 3)}\n${month.year.toString().substring(2)}',
      );
    }

    return labels;
  }

  // Get category legend for pie chart
  static List<Map<String, dynamic>> getCategoryLegend(
    List<Transaction> transactions,
  ) {
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenseTransactions.isEmpty) {
      return [];
    }

    // Group transactions by category
    final categoryTotals = <TransactionCategory, double>{};
    for (final transaction in expenseTransactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // Sort by amount (descending)
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 6 categories
    final topCategories = sortedCategories.take(6).toList();
    final legend = <Map<String, dynamic>>[];

    for (final entry in topCategories) {
      legend.add({
        'name': _getCategoryShortName(entry.key),
        'color': _getCategoryColor(entry.key),
        'value': entry.value,
        'percentage':
            (entry.value / _getTotalExpenses(expenseTransactions)) * 100,
      });
    }

    // Add "Outros" if there are more categories
    final otherCategories = sortedCategories.skip(6).toList();
    if (otherCategories.isNotEmpty) {
      final otherTotal = otherCategories.fold(
        0.0,
        (sum, entry) => sum + entry.value,
      );
      legend.add({
        'name': 'Outros',
        'color': AppConstants.lightGray,
        'value': otherTotal,
        'percentage':
            (otherTotal / _getTotalExpenses(expenseTransactions)) * 100,
      });
    }

    return legend;
  }

  // Helper methods
  static double _getTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static Color _getCategoryColor(TransactionCategory category) {
    // Use a predefined color palette for categories
    const colors = [
      Color(0xFF00509E), // Blue
      Color(0xFF007A33), // Green
      Color(0xFFD62828), // Red
      Color(0xFFFF6B35), // Orange
      Color(0xFF8B5CF6), // Purple
      Color(0xFFF59E0B), // Yellow
    ];

    final index = category.index % colors.length;
    return colors[index];
  }

  static String _getCategoryShortName(TransactionCategory category) {
    switch (category) {
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
      default:
        return 'Outros';
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }
}
