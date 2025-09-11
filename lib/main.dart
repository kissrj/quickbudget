import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'models/transaction.dart';
import 'services/transaction_service.dart';
import 'services/subscription_service.dart';
import 'services/ads_service.dart';
import 'services/pdf_service.dart';
import 'screens/main_navigation.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

// Global provider for the initialized TransactionService
final transactionServiceProvider = Provider<TransactionService>((ref) {
  throw UnimplementedError(
    'TransactionService must be initialized in main.dart',
  );
});

// Global provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  throw UnimplementedError(
    'SubscriptionService must be initialized in main.dart',
  );
});

// Global provider for AdsService
final adsServiceProvider = Provider<AdsService>((ref) {
  throw UnimplementedError('AdsService must be initialized in main.dart');
});

// Global provider for PdfService
final pdfServiceProvider = Provider<PdfService>((ref) {
  throw UnimplementedError('PdfService must be initialized in main.dart');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(TransactionAdapter());

  // Initialize SubscriptionService
  final subscriptionService = SubscriptionService();
  await subscriptionService.init();

  // Initialize TransactionService with SubscriptionService
  final transactionService = TransactionService(subscriptionService);
  await transactionService.init();

  // Initialize AdsService
  final adsService = AdsService(subscriptionService);
  await adsService.init();

  // Initialize PdfService
  final pdfService = PdfService(subscriptionService);

  runApp(
    ProviderScope(
      overrides: [
        transactionServiceProvider.overrideWithValue(transactionService),
        subscriptionServiceProvider.overrideWithValue(subscriptionService),
        adsServiceProvider.overrideWithValue(adsService),
        pdfServiceProvider.overrideWithValue(pdfService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VoiceToTextPage extends StatefulWidget {
  const VoiceToTextPage({super.key, required this.title});

  final String title;

  @override
  State<VoiceToTextPage> createState() => _VoiceToTextPageState();
}

class _VoiceToTextPageState extends State<VoiceToTextPage> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _text = 'Press the microphone button to start speaking...';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    print('Initializing speech recognition...');
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      print('Requesting microphone permission...');
      status = await Permission.microphone.request();
    }
    if (status.isGranted) {
      print('Microphone permission granted');
      _speechEnabled = await _speechToText.initialize(
        onError: (val) => setState(() {
          _isListening = false;
          _text = 'Error: ${val.errorMsg}';
          print('Speech recognition error: ${val.errorMsg}');
        }),
        onStatus: (val) => setState(() {
          _isListening = val == 'listening';
          print('Speech status: $val');
        }),
      );
      print('Speech initialization complete: $_speechEnabled');
    } else {
      print('Microphone permission denied');
      setState(() {
        _text = 'Microphone permission is required for voice recognition.';
      });
    }
    setState(() {});
  }

  void _startListening() async {
    print('Starting to listen...');
    if (!_speechEnabled) {
      print('Speech not enabled');
      return;
    }
    await _speechToText.listen(
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
        print(
          'Recognized words: ${val.recognizedWords} (confidence: ${val.confidence})',
        );
        if (val.hasConfidenceRating && val.confidence > 0) {
          // Optionally handle confidence
        }
      }),
      localeId: 'pt_BR',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    print('Stopping listening...');
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.mic, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_text, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _speechEnabled
                  ? (_isListening ? _stopListening : _startListening)
                  : null,
              tooltip: _isListening ? 'Listening...' : 'Listen',
              child: Icon(_isListening ? Icons.stop : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
