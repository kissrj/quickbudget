import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/upgrade_prompt_widget.dart';
import 'add_transaction_screen.dart';
import '../main.dart'; // Import for providers
import '../l10n/app_localizations.dart';
import '../services/voice_input_service.dart';
import '../models/transaction.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late VoiceInputService _voiceService;
  bool _isListening = false;
  String _voiceStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    _voiceService = VoiceInputService();

    // Set up callbacks
    _voiceService.onResult = _onVoiceResult;
    _voiceService.onError = _onVoiceError;
    _voiceService.onListeningChanged = _onListeningChanged;
    _voiceService.onParsedResult = _onParsedResult;

    await _voiceService.initialize();
  }

  void _onVoiceResult(String result) {
    print('Voice result: $result');
    setState(() {
      _voiceStatus = result;
    });
    // Note: Parsing is now handled in VoiceInputService and will call _onParsedResult
  }

  void _onParsedResult(VoiceParseResult parseResult) {
    print('✅ Parsed voice result successfully: $parseResult');
    _createTransactionFromVoice(parseResult);
  }

  void _onVoiceError(String error) {
    print('Voice error: $error');
    setState(() {
      _isListening = false;
      _voiceStatus = '';
    });

    // Handle specific error cases
    if (error == 'COULD_NOT_UNDERSTAND') {
      // Show "could not understand" message only once per session
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.language == 'pt'
                ? 'Não consegui entender. Tente: "20 mercado"'
                : 'Could not understand. Try: "20 groceries"',
          ),
          backgroundColor: AppConstants.alertColor,
        ),
      );
      return;
    }

    // Only show other error messages
    if (error != 'COULD_NOT_UNDERSTAND') {
      String errorMessage;
      if (error == 'error_speech_timeout') {
        errorMessage = AppLocalizations.of(context)?.language == 'pt'
            ? 'Tempo esgotado. Tente falar mais alto ou mais próximo ao microfone.'
            : 'Timeout. Try speaking louder or closer to the microphone.';
      } else {
        errorMessage = AppLocalizations.of(context)?.language == 'pt'
            ? 'Erro no reconhecimento de voz: $error'
            : 'Voice recognition error: $error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppConstants.alertColor,
        ),
      );
    }
  }

  void _onListeningChanged(bool isListening) {
    print('HomeScreen: Listening state changed to: $isListening');
    setState(() {
      _isListening = isListening;
      if (!isListening) {
        _voiceStatus = '';
      }
    });
  }

  Future<void> _createTransactionFromVoice(VoiceParseResult parseResult) async {
    print('🎯 Creating transaction from voice: $parseResult');

    final transactionService = ref.read(transactionServiceProvider);

    // Get current currency from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('currency') ?? 'BRL';

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: parseResult.amount,
      type: TransactionType.expense, // Default to expense for voice input
      category: parseResult.category,
      description: parseResult.originalInput,
      date: DateTime.now(),
      currency: currency,
    );

    try {
      await transactionService.addTransaction(transaction);
      print('✅ Transaction successfully created: ${transaction.description}');

      // Always show success message when transaction is created
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.language == 'pt'
                  ? '✅ Transação adicionada: R\$ ${parseResult.amount.toStringAsFixed(2)}'
                  : '✅ Transaction added: \$${parseResult.amount.toStringAsFixed(2)}',
            ),
            backgroundColor: AppConstants.positiveColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error creating transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar transação: $e'),
            backgroundColor: AppConstants.alertColor,
          ),
        );
      }
    }
  }

  Future<void> _startVoiceListening() async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    print(
      'HomeScreen: Voice button tapped, current listening state: $_isListening',
    );

    if (!_voiceService.isAvailable) {
      print('HomeScreen: Voice service not available');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.language == 'pt'
                ? 'Serviço de voz não disponível'
                : 'Voice service not available',
          ),
        ),
      );
      return;
    }

    if (_isListening) {
      // If already listening, stop listening
      print('HomeScreen: Already listening, stopping...');
      await _voiceService.stopListening();
    } else {
      // Start listening
      print('HomeScreen: Starting voice listening...');
      await _voiceService.startListening();
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionService = ref.watch(transactionServiceProvider);
    final subscriptionService = ref.watch(subscriptionServiceProvider);

    final totalIncome = transactionService.getTotalIncome();
    final totalExpenses = transactionService.getTotalExpenses();
    final balance = transactionService.getBalance();
    final transactionCount = transactionService.getTransactionCount();

    return Scaffold(
      backgroundColor: const Color(0xFF122118),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Spacer for center alignment
                  Text(
                    AppLocalizations.of(context)?.appName ??
                        AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer for center alignment
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large Circular Microphone Button
                    GestureDetector(
                      onTap: _startVoiceListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isListening
                            ? 200
                            : 192, // Slightly larger when listening
                        height: _isListening ? 200 : 192,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppConstants.alertColor
                              : AppConstants.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isListening
                                          ? AppConstants.alertColor
                                          : AppConstants.primaryColor)
                                      .withOpacity(0.4),
                              blurRadius: _isListening ? 25 : 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          size: _isListening
                              ? 100
                              : 96, // Slightly larger icon when listening
                          color: AppConstants.backgroundColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instruction Text
                    Text(
                      _isListening
                          ? (AppLocalizations.of(context)?.language == 'pt'
                                ? 'Ouvindo... Fale agora'
                                : 'Listening... Speak now')
                          : (AppLocalizations.of(context)?.tapToSpeak ??
                                'Toque para falar'),
                      style: TextStyle(
                        fontSize: 18,
                        color: _isListening
                            ? AppConstants.alertColor
                            : AppConstants.textSecondary,
                        fontWeight: _isListening
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Balance Display (if there are transactions)
                    if (transactionCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)?.currentBalance ??
                                  'Saldo Atual',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'R\$ ${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: balance >= 0
                                    ? AppConstants.primaryColor
                                    : AppConstants.alertColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Free plan limit warning
                    if (!subscriptionService.isPremium &&
                        transactionCount >= AppConstants.freePlanLimit - 2) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: AppConstants.alertColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppConstants.alertColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Limite do plano gratuito',
                              style: TextStyle(
                                color: AppConstants.alertColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${transactionCount}/${AppConstants.freePlanLimit} transações',
                              style: TextStyle(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            UpgradePromptWidget(
                              subscriptionService: subscriptionService,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Floating Action Button (Add Transaction)
            Container(
              padding: const EdgeInsets.only(right: 32, bottom: 32),
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: AppConstants.backgroundColor,
                elevation: 4,
                child: const Icon(Icons.paid, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
