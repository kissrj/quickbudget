import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class VoiceInputService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _hasShownErrorForCurrentSession = false;
  bool _hasProcessedResultForCurrentSession = false;
  bool _hasSuccessfullyCreatedTransaction = false;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onError;
  Function(bool)? onListeningChanged;
  Function(VoiceParseResult)? onParsedResult;

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
          final wasListening = _isListening;
          _isListening = val == 'listening';

          // Only call callback if state actually changed
          if (wasListening != _isListening) {
            print('Listening state changed: $_isListening');
            onListeningChanged?.call(_isListening);
          }
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

    // Reset flags for new session
    _hasShownErrorForCurrentSession = false;
    _hasProcessedResultForCurrentSession = false;
    _hasSuccessfullyCreatedTransaction = false;

    // Set listening state immediately
    _isListening = true;
    onListeningChanged?.call(true);

    try {
      await _speechToText.listen(
        onResult: (val) {
          final recognizedWords = val.recognizedWords.trim();
          print(
            'Recognized words: "$recognizedWords" (final: ${val.finalResult})',
          );

          // Only process final results to avoid duplicate messages
          if (val.finalResult && recognizedWords.isNotEmpty) {
            // If we already successfully created a transaction in this session, ignore further results
            if (_hasSuccessfullyCreatedTransaction) {
              print(
                'Ignoring additional result because transaction was already created successfully',
              );
              return;
            }

            if (!_hasProcessedResultForCurrentSession) {
              _hasProcessedResultForCurrentSession = true;
              onResult?.call(recognizedWords);

              // Try to parse the result
              final parseResult = parseVoiceInput(recognizedWords);
              if (parseResult != null) {
                // Transaction successfully parsed - mark as successful
                _hasSuccessfullyCreatedTransaction = true;
                onParsedResult?.call(parseResult);
                print('Transaction successfully parsed and will be created');
              } else {
                // Only show error if we haven't shown one for this session AND haven't created a transaction
                if (!_hasShownErrorForCurrentSession &&
                    !_hasSuccessfullyCreatedTransaction) {
                  _hasShownErrorForCurrentSession = true;
                  onError?.call('COULD_NOT_UNDERSTAND');
                  print('Could not understand voice input: "$recognizedWords"');
                }
              }
            }
          }
        },
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: false, // Disable partial results to avoid duplicates
        cancelOnError: true,
      );
    } catch (e) {
      print('Error starting voice listening: $e');
      _isListening = false;
      onListeningChanged?.call(false);
      onError?.call('Failed to start voice listening: $e');
    }
  }

  Future<void> stopListening() async {
    print('Stopping voice listening...');
    try {
      await _speechToText.stop();
      // Reset listening state immediately
      _isListening = false;
      onListeningChanged?.call(false);
    } catch (e) {
      print('Error stopping voice listening: $e');
      // Still reset the state even if there's an error
      _isListening = false;
      onListeningChanged?.call(false);
    }
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

    // Create comprehensive keyword sets for each category
    final categoryKeywords = {
      // Portuguese keywords
      'pt': {
        TransactionCategory.groceries: [
          'mercado',
          'compras',
          'supermercado',
          'feira',
          'padaria',
          'açougue',
          'hortifruti',
          'mercearia',
          'minimercado',
          'hipermercado',
          'shopping',
          'loja',
          'comercio',
          'alimentacao',
          'comestivel',
          'produto',
          'item',
          'cesta',
          'sacola',
          'compra',
          'provisionamento',
          'despensa',
          'estoque',
        ],
        TransactionCategory.transportation: [
          'transporte',
          'onibus',
          'metro',
          'trem',
          'taxi',
          'uber',
          'cabify',
          '99',
          'motorista',
          'corrida',
          'viagem',
          'deslocamento',
          'mobilidade',
          'trafego',
          'rodovia',
          'estrada',
          'gasolina',
          'combustivel',
          'posto',
          'abastecimento',
          'pedagio',
          'estacionamento',
          'garagem',
          'bicicleta',
          'moto',
          'motocicleta',
          'carro',
          'veiculo',
          'automovel',
        ],
        TransactionCategory.housing: [
          'casa',
          'moradia',
          'aluguel',
          'iptu',
          'condominio',
          'manutencao',
          'reforma',
          'construcao',
          'imovel',
          'apartamento',
          'residencia',
          'habitacao',
          'propriedade',
          'casa propria',
          'financiamento',
          'hipoteca',
          'seguro',
          'seguro habitacional',
          'taxa',
          'imposto',
          'predial',
          'reparos',
          'pintura',
          'eletricista',
          'encanador',
          'faxineira',
        ],
        TransactionCategory.entertainment: [
          'cinema',
          'lazer',
          'entretenimento',
          'diversao',
          'show',
          'teatro',
          'musica',
          'concerto',
          'festival',
          'parque',
          'brincadeira',
          'jogo',
          'videogame',
          'filme',
          'serie',
          'netflix',
          'spotify',
          'amazon',
          'disney',
          'hbo',
          'streaming',
          'ingressos',
          'bilhete',
          'evento',
          'festa',
          'aniversario',
          'casamento',
          'formatura',
          'viagem',
        ],
        TransactionCategory.health: [
          'saude',
          'medico',
          'hospital',
          'remedio',
          'farmacia',
          'consulta',
          'exame',
          'laboratorio',
          'dentista',
          'oftalmologista',
          'psicologo',
          'terapeuta',
          'massagem',
          'academia',
          'ginastica',
          'musculacao',
          'esporte',
          'corrida',
          'natacao',
          'pilates',
          'yoga',
          'meditacao',
          'plano',
          'convenio',
          'emergencia',
          'urgencia',
          'vacina',
        ],
        TransactionCategory.food: [
          'comida',
          'alimentacao',
          'restaurante',
          'lanche',
          'cafe',
          'jantar',
          'almoco',
          'refeicao',
          'fast food',
          'lanchonete',
          'pizzaria',
          'churrascaria',
          'sorveteria',
          'doceria',
          'padaria',
          'confeitaria',
          'buffet',
          'self service',
          'delivery',
          'ifood',
          'rappi',
          'ubereats',
          'pedido',
          'comida rapida',
          'marmita',
          'quentinha',
          'salgado',
          'doce',
          'bebida',
        ],
        TransactionCategory.utilities: [
          'conta',
          'luz',
          'energia',
          'eletrica',
          'agua',
          'esgoto',
          'gas',
          'internet',
          'banda larga',
          'wifi',
          'telefone',
          'celular',
          'fixo',
          'tim',
          'vivo',
          'claro',
          'oi',
          'telefonia',
          'tv',
          'cabo',
          'net',
          'provedor',
          'servico',
          'utilitario',
          'despesa',
          'mensalidade',
          'assinatura',
          'plano',
          'pacote',
          'servicos publicos',
        ],
        TransactionCategory.shopping: [
          'roupa',
          'vestuario',
          'calcado',
          'sapato',
          'tenis',
          'acessorio',
          'bolsa',
          'joia',
          'relogio',
          'oculos',
          'chapéu',
          'cachecol',
          'luva',
          'cinto',
          'meia',
          'roupa intima',
          'lingerie',
          'perfume',
          'cosmetico',
          'maquiagem',
          'creme',
          'shampoo',
          'sabonete',
          'higiene',
          'beleza',
          'salao',
          'cabelereiro',
          'manicure',
          'pedicure',
        ],
        TransactionCategory.education: [
          'escola',
          'faculdade',
          'universidade',
          'curso',
          'aula',
          'professor',
          'material',
          'livro',
          'caderno',
          'lapis',
          'caneta',
          'mochila',
          'estojo',
          'apostila',
          'didatico',
          'ensino',
          'aprendizado',
          'formacao',
          'capacitacao',
          'treinamento',
          'workshop',
          'palestra',
          'congresso',
          'seminario',
          'conferencia',
          'certificacao',
          'diploma',
          'graduacao',
          'pos',
        ],
        TransactionCategory.personal: [
          'pessoal',
          'beleza',
          'cabelo',
          'unha',
          'depilacao',
          'limpeza',
          'facial',
          'corporal',
          'massagem',
          'relaxamento',
          'spa',
          'banho',
          'higiene',
          'cuidados',
          'autocuidado',
          'bem estar',
          'saude mental',
          'terapia',
          'psicologia',
          'coaching',
          'desenvolvimento',
          'crescimento',
          'motivacao',
          'inspiração',
          'hobby',
          'passatempo',
          'lazer pessoal',
        ],
        TransactionCategory.salary: [
          'salario',
          'ordenado',
          'vencimento',
          'pagamento',
          'folha',
          'contra cheque',
          'deposito',
          'transferencia',
          'pix',
          'dinheiro',
          'renda',
          'ganho',
          'remuneracao',
          'compensacao',
          'provento',
          'vencimento',
          'mensal',
          'quinzenal',
          'semanal',
          'diario',
          'hora extra',
          'adicional',
          'gratificacao',
          'premio',
          'bonus',
          'comissao',
          'participacao',
          'lucro',
        ],
        TransactionCategory.freelance: [
          'freelance',
          'freela',
          'autonomo',
          'independente',
          'trabalho',
          'servico',
          'projeto',
          'contrato',
          'prestacao',
          'consultoria',
          'assessoria',
          'parceria',
          'colaboração',
          'trabalho remoto',
          'home office',
          'gig economy',
          'uber',
          '99',
          'rappi',
          'ifood',
          'task',
          'missao',
          'tarefa',
          'atividade',
          'empreitada',
          'obra',
          'servico tecnico',
          'manutencao',
        ],
        TransactionCategory.investments: [
          'investimento',
          'acao',
          'dividendo',
          'renda',
          'juros',
          'capital',
          'aplicacao',
          'poupanca',
          'cdb',
          'tesouro',
          'fundo',
          'previdencia',
          'seguro',
          'cripto',
          'bitcoin',
          'ethereum',
          'trading',
          'corretora',
          'banco',
          'financiamento',
          'emprestimo',
          'credito',
          'cartao',
          'fatura',
          'pagamento',
          'parcela',
          'financiamento',
        ],
        TransactionCategory.rental: [
          'aluguel',
          'locacao',
          'imovel',
          'apartamento',
          'casa',
          'sala',
          'loja',
          'escritorio',
          'galpao',
          'terreno',
          'propriedade',
          'inquilino',
          'locador',
          'contrato',
          'fiador',
          'garantia',
          'caucao',
          'seguro fiança',
          'iptu',
          'condominio',
          'manutencao',
          'reforma',
          'pintura',
          'reparos',
          'taxa',
          'administracao',
          'sindico',
          'portaria',
          'elevador',
        ],
        TransactionCategory.business: [
          'negocio',
          'empresa',
          'comercio',
          'venda',
          'compra',
          'produto',
          'servico',
          'cliente',
          'fornecedor',
          'parceiro',
          'socio',
          'funcionario',
          'salario',
          'folha',
          'imposto',
          'tributo',
          'nota fiscal',
          'recibo',
          'contrato',
          'proposta',
          'orcamento',
          'custo',
          'despesa',
          'investimento',
          'capital',
          'lucro',
          'receita',
          'faturamento',
          'vendas',
          'marketing',
        ],
        TransactionCategory.gifts: [
          'presente',
          'doacao',
          'brinde',
          'bonus',
          'gratuito',
          'cortesia',
          'oferta',
          'promocao',
          'desconto',
          'vale',
          'cupom',
          'premio',
          'sorteio',
          'concurso',
          'rifa',
          'caridade',
          'ajuda',
          'auxilio',
          'beneficio',
          'bolsa',
          'estipendio',
          'mesada',
          'pensão',
          'aposentadoria',
          'heranca',
          'ganho extra',
          'bico',
          'freela',
          'adicional',
        ],
        TransactionCategory.other: [
          'outro',
          'diverso',
          'miscelanea',
          'geral',
          'comum',
          'padrao',
          'normal',
          'regular',
          'habitual',
          'rotineiro',
          'cotidiano',
          'diario',
          'semanal',
          'mensal',
          'anual',
          'ocasional',
          'eventual',
          'esporadico',
          'extraordinario',
          'excepcional',
          'atipico',
        ],
      },

      // English keywords
      'en': {
        TransactionCategory.groceries: [
          'groceries',
          'shopping',
          'supermarket',
          'market',
          'store',
          'food',
          'produce',
          'bakery',
          'butcher',
          'deli',
          'convenience',
          'hypermarket',
          'mall',
          'shop',
          'commerce',
          'grocery',
          'item',
          'product',
          'goods',
          'supplies',
          'provisions',
          'pantry',
          'stock',
          'inventory',
          'basket',
          'bag',
          'purchase',
          'buy',
          'acquire',
          'obtain',
        ],
        TransactionCategory.transportation: [
          'transport',
          'transportation',
          'bus',
          'train',
          'subway',
          'metro',
          'taxi',
          'uber',
          'lyft',
          'driver',
          'ride',
          'trip',
          'journey',
          'travel',
          'commute',
          'mobility',
          'traffic',
          'highway',
          'road',
          'gas',
          'fuel',
          'gas station',
          'petrol',
          'toll',
          'parking',
          'garage',
          'bicycle',
          'bike',
          'motorcycle',
          'car',
          'vehicle',
          'automobile',
          'auto',
        ],
        TransactionCategory.housing: [
          'house',
          'housing',
          'home',
          'rent',
          'rental',
          'property',
          'tax',
          'condo',
          'apartment',
          'residence',
          'dwelling',
          'ownership',
          'mortgage',
          'insurance',
          'home insurance',
          'fee',
          'repair',
          'maintenance',
          'fix',
          'paint',
          'electrician',
          'plumber',
          'cleaner',
          'housekeeper',
          'maid',
          'gardener',
          'landscaping',
          'roof',
          'window',
          'door',
        ],
        TransactionCategory.entertainment: [
          'entertainment',
          'movies',
          'cinema',
          'fun',
          'leisure',
          'show',
          'theater',
          'music',
          'concert',
          'festival',
          'park',
          'amusement',
          'game',
          'gaming',
          'video game',
          'film',
          'movie',
          'series',
          'netflix',
          'spotify',
          'amazon',
          'disney',
          'hbo',
          'streaming',
          'ticket',
          'event',
          'party',
          'birthday',
          'wedding',
          'graduation',
          'vacation',
          'holiday',
          'trip',
        ],
        TransactionCategory.health: [
          'health',
          'medical',
          'doctor',
          'hospital',
          'medicine',
          'pharmacy',
          'consultation',
          'exam',
          'laboratory',
          'dentist',
          'eye doctor',
          'therapist',
          'massage',
          'gym',
          'fitness',
          'workout',
          'exercise',
          'running',
          'swimming',
          'pilates',
          'yoga',
          'meditation',
          'plan',
          'insurance',
          'emergency',
          'urgent care',
          'vaccine',
          'checkup',
          'appointment',
          'prescription',
        ],
        TransactionCategory.food: [
          'food',
          'dining',
          'restaurant',
          'meal',
          'lunch',
          'dinner',
          'snack',
          'fast food',
          'cafe',
          'coffee',
          'pizzeria',
          'steakhouse',
          'ice cream',
          'bakery',
          'pastry',
          'buffet',
          'catering',
          'delivery',
          'takeout',
          'cuisine',
          'eating',
          'nutrition',
          'diet',
          'meal prep',
          'catering',
          'banquet',
          'feast',
          'refreshment',
          'beverage',
          'drink',
        ],
        TransactionCategory.utilities: [
          'utilities',
          'electricity',
          'power',
          'electric',
          'water',
          'sewage',
          'gas',
          'internet',
          'broadband',
          'wifi',
          'phone',
          'cell',
          'mobile',
          'landline',
          'telephony',
          'cable',
          'tv',
          'provider',
          'service',
          'bill',
          'monthly',
          'subscription',
          'plan',
          'package',
          'public services',
          'municipal',
          'utility bill',
          'energy bill',
          'water bill',
        ],
        TransactionCategory.shopping: [
          'shopping',
          'clothes',
          'clothing',
          'shoes',
          'sneakers',
          'accessories',
          'bag',
          'jewelry',
          'watch',
          'glasses',
          'hat',
          'scarf',
          'glove',
          'belt',
          'sock',
          'underwear',
          'lingerie',
          'perfume',
          'cosmetic',
          'makeup',
          'cream',
          'shampoo',
          'soap',
          'hygiene',
          'beauty',
          'salon',
          'haircut',
          'manicure',
          'pedicure',
          'spa',
          'facial',
          'treatment',
        ],
        TransactionCategory.education: [
          'education',
          'school',
          'college',
          'university',
          'course',
          'class',
          'teacher',
          'professor',
          'material',
          'book',
          'notebook',
          'pencil',
          'pen',
          'backpack',
          'textbook',
          'study',
          'learning',
          'training',
          'workshop',
          'seminar',
          'conference',
          'certification',
          'diploma',
          'degree',
          'graduation',
          'postgraduate',
          'master',
          'phd',
          'tuition',
        ],
        TransactionCategory.personal: [
          'personal',
          'beauty',
          'hair',
          'nail',
          'waxing',
          'cleaning',
          'facial',
          'body',
          'massage',
          'relaxation',
          'spa',
          'bath',
          'hygiene',
          'care',
          'self care',
          'wellness',
          'mental health',
          'therapy',
          'psychology',
          'coaching',
          'development',
          'growth',
          'motivation',
          'inspiration',
          'hobby',
          'pastime',
          'personal leisure',
          'grooming',
          'appearance',
        ],
        TransactionCategory.salary: [
          'salary',
          'wage',
          'pay',
          'payment',
          'payroll',
          'deposit',
          'transfer',
          'income',
          'earnings',
          'compensation',
          'remuneration',
          'stipend',
          'allowance',
          'pension',
          'retirement',
          'monthly',
          'biweekly',
          'weekly',
          'daily',
          'overtime',
          'bonus',
          'commission',
          'profit share',
          'dividend',
          'royalty',
          'fee',
          'honorarium',
          'per diem',
          'allowance',
        ],
        TransactionCategory.freelance: [
          'freelance',
          'freelancer',
          'independent',
          'contractor',
          'gig',
          'side',
          'consultant',
          'advisor',
          'partner',
          'collaboration',
          'remote work',
          'home office',
          'gig economy',
          'task',
          'mission',
          'job',
          'assignment',
          'project',
          'contract',
          'service',
          'technical service',
          'repair',
          'maintenance',
          'installation',
          'setup',
          'configuration',
        ],
        TransactionCategory.investments: [
          'investment',
          'stock',
          'dividend',
          'interest',
          'capital',
          'savings',
          'bank',
          'account',
          'deposit',
          'withdrawal',
          'transfer',
          'crypto',
          'bitcoin',
          'ethereum',
          'trading',
          'brokerage',
          'portfolio',
          'fund',
          'mutual fund',
          'retirement',
          'pension',
          'insurance',
          'premium',
          'policy',
          'coverage',
          'claim',
          'benefit',
          'annuity',
        ],
        TransactionCategory.rental: [
          'rental',
          'lease',
          'property',
          'apartment',
          'house',
          'office',
          'store',
          'warehouse',
          'land',
          'real estate',
          'tenant',
          'landlord',
          'leasehold',
          'tenancy',
          'occupancy',
          'possession',
          'guarantor',
          'security deposit',
          'rental insurance',
          'property tax',
          'condo fee',
          'hoa',
          'maintenance',
          'repair',
          'renovation',
          'improvement',
          'upgrade',
          'modification',
        ],
        TransactionCategory.business: [
          'business',
          'company',
          'commerce',
          'sale',
          'purchase',
          'product',
          'service',
          'client',
          'customer',
          'supplier',
          'vendor',
          'partner',
          'associate',
          'employee',
          'staff',
          'payroll',
          'tax',
          'invoice',
          'receipt',
          'contract',
          'proposal',
          'quote',
          'cost',
          'expense',
          'investment',
          'capital',
          'profit',
          'revenue',
          'sales',
          'marketing',
          'advertising',
        ],
        TransactionCategory.gifts: [
          'gift',
          'donation',
          'bonus',
          'free',
          'complimentary',
          'offer',
          'promotion',
          'discount',
          'voucher',
          'coupon',
          'prize',
          'award',
          'lottery',
          'raffle',
          'charity',
          'aid',
          'assistance',
          'benefit',
          'grant',
          'scholarship',
          'stipend',
          'allowance',
          'pension',
          'inheritance',
          'windfall',
          'jackpot',
          'surprise',
          'unexpected',
          'bonus',
        ],
        TransactionCategory.other: [
          'other',
          'miscellaneous',
          'misc',
          'general',
          'common',
          'standard',
          'normal',
          'regular',
          'habitual',
          'routine',
          'daily',
          'weekly',
          'monthly',
          'yearly',
          'occasional',
          'eventual',
          'sporadic',
          'extraordinary',
          'exceptional',
          'atypical',
          'unusual',
          'different',
          'various',
        ],
      },
    };

    // Check if the category string matches any keyword
    final keywords =
        categoryKeywords[language]?[TransactionCategory.groceries] ?? [];
    for (final category in TransactionCategory.values) {
      final categoryKeywordsList = categoryKeywords[language]?[category] ?? [];
      if (categoryKeywordsList.contains(lowerCategory)) {
        return category;
      }
    }

    return TransactionCategory.other; // Default fallback
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
