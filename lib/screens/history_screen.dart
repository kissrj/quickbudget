import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'home_screen.dart'; // Import for transactionsProvider
import '../main.dart';
import '../services/pdf_service.dart';
import '../services/subscription_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _selectedType;
  TransactionCategory? _selectedCategory;
  String _searchQuery = '';
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!transaction.description.toLowerCase().contains(query) &&
            !transaction.categoryDisplayName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null &&
          transaction.category != _selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final notifier = ref.read(transactionsProvider.notifier);
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final pdfService = ref.watch(pdfServiceProvider);
    final filteredTransactions = _filterTransactions(transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          if (subscriptionService.isPremium)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Exportar PDF',
              onPressed: () =>
                  _exportToPdf(context, pdfService, filteredTransactions),
            ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar transações...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filters (when expanded)
          if (_showFilters) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Type Filter
                  Row(
                    children: [
                      const Text(
                        'Tipo:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SegmentedButton<TransactionType?>(
                          segments: const [
                            ButtonSegment(value: null, label: Text('Todos')),
                            ButtonSegment(
                              value: TransactionType.income,
                              label: Text('Receitas'),
                            ),
                            ButtonSegment(
                              value: TransactionType.expense,
                              label: Text('Despesas'),
                            ),
                          ],
                          selected: {_selectedType},
                          onSelectionChanged: (Set<TransactionType?> selected) {
                            setState(() {
                              _selectedType = selected.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Filter
                  Row(
                    children: [
                      const Text(
                        'Categoria:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<TransactionCategory?>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          hint: const Text('Todas'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todas'),
                            ),
                            ...TransactionCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(_getCategoryDisplayName(category)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Clear Filters Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedType = null;
                          _selectedCategory = null;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      child: const Text('Limpar Filtros'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Results Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTransactions.length} transação${filteredTransactions.length != 1 ? 'ões' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (filteredTransactions.isNotEmpty)
                  Text(
                    'Total: R\$ ${_calculateTotal(filteredTransactions).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _calculateTotal(filteredTransactions) >= 0
                          ? AppConstants.positiveColor
                          : AppConstants.alertColor,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transaction List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          transactions.isEmpty
                              ? 'Nenhuma transação encontrada'
                              : 'Nenhuma transação corresponde aos filtros',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
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
                          child: const Icon(Icons.delete, color: Colors.white),
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
                                      foregroundColor: AppConstants.alertColor,
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
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  transaction.type == TransactionType.income
                                  ? AppConstants.positiveColor.withOpacity(0.1)
                                  : AppConstants.expenseColor.withOpacity(0.1),
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
                              '${transaction.categoryDisplayName} • ${_formatDate(transaction.date)}',
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Show transaction details
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(List<Transaction> transactions) {
    return transactions.fold(0.0, (total, transaction) {
      return total +
          (transaction.type == TransactionType.income
              ? transaction.amount
              : -transaction.amount);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getCategoryDisplayName(TransactionCategory category) {
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

  Future<void> _exportToPdf(
    BuildContext context,
    PdfService pdfService,
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma transação para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Gerando PDF...'),
              ],
            ),
          );
        },
      );

      // Generate title based on filters
      String title = 'Relatório de Transações';
      if (_selectedType != null) {
        title +=
            ' - ${_selectedType == TransactionType.income ? 'Receitas' : 'Despesas'}';
      }
      if (_selectedCategory != null) {
        title += ' - ${_getCategoryDisplayName(_selectedCategory!)}';
      }
      if (_searchQuery.isNotEmpty) {
        title += ' (Busca: $_searchQuery)';
      }

      // Generate PDF
      await pdfService.generateTransactionReport(context, transactions, title);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
