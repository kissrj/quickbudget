import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class VoiceInputService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onError;
  Function(bool)? onListeningChanged;

  Future<bool> initialize() async {
    print('Initializing voice input service...');

    // Request microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      print('Requesting microphone permission...');
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      print('Microphone permission granted');
      _speechEnabled = await _speechToText.initialize(
        onError: (val) {
          print('Speech recognition error: ${val.errorMsg}');
          onError?.call(val.errorMsg);
        },
        onStatus: (val) {
          print('Speech status: $val');
          _isListening = val == 'listening';
          onListeningChanged?.call(_isListening);
        },
      );
      print('Voice input service initialized: $_speechEnabled');
      return _speechEnabled;
    } else {
      print('Microphone permission denied');
      onError?.call('Microphone permission is required for voice input');
      return false;
    }
  }

  Future<void> startListening({
    String localeId = 'pt_BR',
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_speechEnabled) {
      onError?.call('Voice input service not initialized');
      return;
    }

    print('Starting voice listening...');
    await _speechToText.listen(
      onResult: (val) {
        final recognizedWords = val.recognizedWords;
        print('Recognized words: $recognizedWords');
        onResult?.call(recognizedWords);
      },
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> stopListening() async {
    print('Stopping voice listening...');
    await _speechToText.stop();
  }

  bool get isListening => _isListening;
  bool get isAvailable => _speechEnabled;

  // Parse voice input to extract amount and category
  VoiceParseResult? parseVoiceInput(String input) {
    print('Parsing voice input: $input');

    // Clean the input
    final cleanInput = input.toLowerCase().trim();

    // Portuguese patterns
    final ptPatterns = [
      // "20 reais no mercado" or "20 no mercado"
      RegExp(
        r'(\d+(?:[,.]\d{1,2})?)\s*(?:reais?|reais?)\s*(?:no|na|em)\s+(\w+)',
      ),
      // "20 mercado"
      RegExp(r'(\d+(?:[,.]\d{1,2})?)\s+(\w+)'),
    ];

    // English patterns
    final enPatterns = [
      // "$20 in groceries" or "20 dollars in groceries"
      RegExp(
        r'(?:\$|dollar)?\s*(\d+(?:[,.]\d{1,2})?)\s*(?:dollars?|in)\s+(\w+)',
      ),
      // "20 groceries"
      RegExp(r'(\d+(?:[,.]\d{1,2})?)\s+(\w+)'),
    ];

    // Try Portuguese patterns first
    for (final pattern in ptPatterns) {
      final match = pattern.firstMatch(cleanInput);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '.');
        final categoryStr = match.group(2);

        if (amountStr != null && categoryStr != null) {
          final amount = double.tryParse(amountStr);
          final category = _mapCategory(categoryStr, 'pt');

          if (amount != null && category != null) {
            return VoiceParseResult(
              amount: amount,
              category: category,
              originalInput: input,
            );
          }
        }
      }
    }

    // Try English patterns
    for (final pattern in enPatterns) {
      final match = pattern.firstMatch(cleanInput);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '.');
        final categoryStr = match.group(2);

        if (amountStr != null && categoryStr != null) {
          final amount = double.tryParse(amountStr);
          final category = _mapCategory(categoryStr, 'en');

          if (amount != null && category != null) {
            return VoiceParseResult(
              amount: amount,
              category: category,
              originalInput: input,
            );
          }
        }
      }
    }

    return null; // Could not parse
  }

  TransactionCategory? _mapCategory(String categoryStr, String language) {
    final lowerCategory = categoryStr.toLowerCase();

    if (language == 'pt') {
      switch (lowerCategory) {
        case 'mercado':
        case 'compras':
        case 'supermercado':
          return TransactionCategory.groceries;
        case 'transporte':
        case 'onibus':
        case 'metro':
        case 'taxi':
        case 'uber':
          return TransactionCategory.transportation;
        case 'casa':
        case 'moradia':
        case 'aluguel':
        case 'conta':
          return TransactionCategory.housing;
        case 'cinema':
        case 'lazer':
        case 'entretenimento':
        case 'diversao':
          return TransactionCategory.entertainment;
        case 'saude':
        case 'medico':
        case 'hospital':
        case 'remedio':
          return TransactionCategory.health;
        default:
          return TransactionCategory.other;
      }
    } else {
      // English
      switch (lowerCategory) {
        case 'groceries':
        case 'shopping':
        case 'supermarket':
          return TransactionCategory.groceries;
        case 'transport':
        case 'transportation':
        case 'bus':
        case 'train':
        case 'taxi':
        case 'uber':
          return TransactionCategory.transportation;
        case 'house':
        case 'housing':
        case 'rent':
        case 'utilities':
          return TransactionCategory.housing;
        case 'entertainment':
        case 'movies':
        case 'fun':
          return TransactionCategory.entertainment;
        case 'health':
        case 'medical':
        case 'doctor':
        case 'medicine':
          return TransactionCategory.health;
        default:
          return TransactionCategory.other;
      }
    }
  }

  void dispose() {
    _speechToText.cancel();
  }
}

class VoiceParseResult {
  final double amount;
  final TransactionCategory category;
  final String originalInput;

  VoiceParseResult({
    required this.amount,
    required this.category,
    required this.originalInput,
  });

  @override
  String toString() {
    return 'VoiceParseResult(amount: $amount, category: $category, input: $originalInput)';
  }
}
