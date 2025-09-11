import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/charts_service.dart';
import '../utils/constants.dart';
import '../screens/home_screen.dart'; // Import for transactionsProvider

class ChartsWidget extends ConsumerWidget {
  const ChartsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    // Debug: Print transaction count
    print('ChartsWidget: Building with ${transactions.length} transactions');

    return Container(
      color: Colors.yellow.withOpacity(0.1), // Debug: Make charts area visible
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Debug text
          Text(
            'DEBUG: ${transactions.length} transactions',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Pie Chart for Expense Categories
          _buildPieChartSection(context, transactions),

          const SizedBox(height: 24),

          // Bar Chart for Monthly Evolution
          _buildBarChartSection(context, transactions),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final pieSections = ChartsService.generateExpensePieChart(transactions);
    final legend = ChartsService.getCategoryLegend(transactions);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição de Despesas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  centerSpaceColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: legend.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['name']} (${item['percentage'].toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartSection(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final barGroups = ChartsService.generateMonthlyBarChart(transactions);
    final monthLabels = ChartsService.getMonthLabels();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolução Mensal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < monthLabels.length) {
                            return Text(
                              monthLabels[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'R\$${value.abs().toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 500,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppConstants.primaryColor,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final isIncome = rodIndex == 0;
                        final value = rod.toY.abs();
                        return BarTooltipItem(
                          '${isIncome ? 'Receitas' : 'Despesas'}: R\$${value.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend for bar chart
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: AppConstants.positiveColor,
                    ),
                    const SizedBox(width: 4),
                    const Text('Receitas', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: AppConstants.expenseColor,
                    ),
                    const SizedBox(width: 4),
                    const Text('Despesas', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
