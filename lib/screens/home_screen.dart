import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import '../services/transaction_service.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import '../main.dart'; // Import for transactionServiceProvider
import '../widgets/charts_widget.dart';
import '../widgets/upgrade_prompt_widget.dart';
import '../services/subscription_service.dart';
import '../services/ads_service.dart';

// Provider for transactions list
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
      final service = ref.watch(transactionServiceProvider);
      return TransactionsNotifier(service);
    });

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final TransactionService _service;

  TransactionsNotifier(this._service) : super([]) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    state = _service.getAllTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _service.addTransaction(transaction);
    // Reload all transactions from database to ensure consistency
    state = _service.getAllTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _service.updateTransaction(transaction);
    state = state.map((t) => t.id == transaction.id ? transaction : t).toList();
  }

  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
    // Reload all transactions from database to ensure consistency
    state = _service.getAllTransactions();
  }

  double get balance => _service.getBalance();
  double get totalIncome => _service.getTotalIncome();
  double get totalExpenses => _service.getTotalExpenses();
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final notifier = ref.read(transactionsProvider.notifier);
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final adsService = ref.watch(adsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Atual',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${notifier.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: notifier.balance >= 0
                            ? AppConstants.positiveColor
                            : AppConstants.alertColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: AppConstants.positiveColor,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Receitas',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            'R\$ ${notifier.totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.positiveColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            color: AppConstants.expenseColor,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Despesas',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            'R\$ ${notifier.totalExpenses.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.expenseColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Upgrade Prompt (shown when user reaches limit)
            UpgradePromptWidget(subscriptionService: subscriptionService),

            const SizedBox(height: 24),

            // Charts Section
            const ChartsWidget(),

            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transações Recentes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Transaction List
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma transação ainda',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toque no botão + para adicionar',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: transactions.length > 5
                          ? 5
                          : transactions.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            transactions[transactions.length - 1 - index];
                        return Dismissible(
                          key: Key(transaction.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppConstants.alertColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar exclusão'),
                                  content: Text(
                                    'Deseja excluir a transação "${transaction.description}"?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppConstants.alertColor,
                                      ),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            notifier.deleteTransaction(transaction.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Transação "${transaction.description}" excluída',
                                ),
                                action: SnackBarAction(
                                  label: 'Desfazer',
                                  onPressed: () {
                                    notifier.addTransaction(transaction);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    transaction.type == TransactionType.income
                                    ? AppConstants.positiveColor.withOpacity(
                                        0.1,
                                      )
                                    : AppConstants.expenseColor.withOpacity(
                                        0.1,
                                      ),
                                child: Icon(
                                  transaction.type == TransactionType.income
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color:
                                      transaction.type == TransactionType.income
                                      ? AppConstants.positiveColor
                                      : AppConstants.expenseColor,
                                ),
                              ),
                              title: Text(
                                transaction.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${transaction.categoryDisplayName} • ${transaction.date.day}/${transaction.date.month}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    transaction.formattedAmount,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          transaction.type ==
                                              TransactionType.income
                                          ? AppConstants.positiveColor
                                          : AppConstants.expenseColor,
                                    ),
                                  ),
                                  Text(
                                    transaction.typeDisplayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // TODO: Navigate to transaction details/edit
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: adsService.getBannerAdWidget(),
    );
  }
}
