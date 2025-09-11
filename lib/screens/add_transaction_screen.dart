import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/voice_input_service.dart';
import '../utils/constants.dart';
import '../main.dart'; // Import for transactionServiceProvider
import 'home_screen.dart'; // Import for transactionsProvider

// Provider for VoiceInputService
final voiceInputServiceProvider = Provider<VoiceInputService>((ref) {
  return VoiceInputService();
});

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _transactionType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.groceries;
  bool _isVoiceMode = false;
  bool _isListening = false;
  String _voiceText = '';
  VoiceParseResult? _parsedResult;

  late VoiceInputService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = ref.read(voiceInputServiceProvider);
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    final initialized = await _voiceService.initialize();
    if (!initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao inicializar entrada por voz'),
            backgroundColor: AppConstants.alertColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (!_isVoiceMode) {
        _stopListening();
      }
    });
  }

  Future<void> _startListening() async {
    if (!_voiceService.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço de voz não disponível'),
          backgroundColor: AppConstants.alertColor,
        ),
      );
      return;
    }

    _voiceService.onResult = (text) {
      setState(() {
        _voiceText = text;
        _parsedResult = _voiceService.parseVoiceInput(text);
        if (_parsedResult != null) {
          _amountController.text = _parsedResult!.amount.toStringAsFixed(2);
          _selectedCategory = _parsedResult!.category;
          _descriptionController.text = _getCategoryDescription(
            _parsedResult!.category,
          );
        }
      });
    };

    _voiceService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na entrada por voz: $error'),
            backgroundColor: AppConstants.alertColor,
          ),
        );
      }
    };

    _voiceService.onListeningChanged = (isListening) {
      setState(() {
        _isListening = isListening;
      });
    };

    await _voiceService.startListening();
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  String _getCategoryDescription(TransactionCategory category) {
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

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor inválido'),
          backgroundColor: AppConstants.alertColor,
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descriptionController.text,
      amount: amount,
      type: _transactionType,
      category: _selectedCategory,
      date: DateTime.now(),
      currency: 'BRL',
    );

    try {
      // Use the notifier to update both database and UI state
      final notifier = ref.read(transactionsProvider.notifier);
      await notifier.addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_transactionType == TransactionType.income ? 'Receita' : 'Despesa'} adicionada com sucesso!',
            ),
            backgroundColor: AppConstants.positiveColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppConstants.alertColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Transação'),
        actions: [
          IconButton(
            icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic),
            onPressed: _toggleVoiceMode,
            tooltip: _isVoiceMode ? 'Modo manual' : 'Modo voz',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voice input section
              if (_isVoiceMode) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mic,
                          size: 64,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isListening ? 'Ouvindo...' : 'Toque para falar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_voiceText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _voiceText,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isListening
                              ? _stopListening
                              : _startListening,
                          icon: Icon(_isListening ? Icons.stop : Icons.mic),
                          label: Text(_isListening ? 'Parar' : 'Começar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isListening
                                ? AppConstants.alertColor
                                : AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Exemplos: "20 mercado" ou "30 44 transporte"',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Manual input form
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction type selector
                      const Text(
                        'Tipo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<TransactionType>(
                        segments: const [
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text('Despesa'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text('Receita'),
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                        selected: {_transactionType},
                        onSelectionChanged: (Set<TransactionType> selected) {
                          setState(() {
                            _transactionType = selected.first;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um valor';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma descrição';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Category selector
                      const Text(
                        'Categoria',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TransactionCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _getAvailableCategories().map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryDisplayName(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvar Transação',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TransactionCategory> _getAvailableCategories() {
    if (_transactionType == TransactionType.expense) {
      // Expense categories
      return [
        TransactionCategory.groceries,
        TransactionCategory.transportation,
        TransactionCategory.housing,
        TransactionCategory.entertainment,
        TransactionCategory.health,
        TransactionCategory.food,
        TransactionCategory.utilities,
        TransactionCategory.shopping,
        TransactionCategory.education,
        TransactionCategory.personal,
        TransactionCategory.other,
      ];
    } else {
      // Income categories
      return [
        TransactionCategory.salary,
        TransactionCategory.freelance,
        TransactionCategory.investments,
        TransactionCategory.rental,
        TransactionCategory.business,
        TransactionCategory.gifts,
        TransactionCategory.other,
      ];
    }
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
}
