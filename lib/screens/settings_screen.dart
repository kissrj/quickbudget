import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../services/subscription_service.dart';
import '../services/data_export_service.dart';
import '../widgets/upgrade_prompt_widget.dart';
import '../main.dart'; // Import for subscriptionServiceProvider
import '../providers/theme_provider.dart' as theme_provider;

class SettingsScreen extends ConsumerStatefulWidget {
  final Function(String)? onLanguageChange;
  final Locale? currentLocale;

  const SettingsScreen({Key? key, this.onLanguageChange, this.currentLocale})
    : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'pt';
  String _selectedCurrency = 'BRL';
  String _selectedTheme = 'auto'; // 'auto', 'dark', 'light'

  final Map<String, String> _currencies = {
    'BRL': 'Real (R\$)',
    'USD': 'Dólar (\$)',
    'EUR': 'Euro (€)',
    'GBP': 'Libra (£)',
    'JPY': 'Iene (¥)',
    'CAD': 'Dólar Canadense (C\$)',
    'AUD': 'Dólar Australiano (A\$)',
    'CHF': 'Franco Suíço (Fr)',
    'CNY': 'Yuan Chinês (¥)',
    'ARS': 'Peso Argentino (\$)',
    'MXN': 'Peso Mexicano (\$)',
    'CLP': 'Peso Chileno (\$)',
    'COP': 'Peso Colombiano (\$)',
    'PEN': 'Sol Peruano (S/)',
    'UYU': 'Peso Uruguaio (\$)',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'pt';
      _selectedCurrency = prefs.getString('currency') ?? 'BRL';
      _selectedTheme = prefs.getString('theme') ?? 'auto';
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionService = ref.watch(subscriptionServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF122118),
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFF122118),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção de Plano
          _buildSectionHeader('Plano'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    subscriptionService.isPremium
                        ? Icons.star
                        : Icons.star_border,
                    color: subscriptionService.isPremium
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  title: Text(
                    subscriptionService.isPremium
                        ? 'Premium Ativo'
                        : 'Plano Free',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: subscriptionService.isPremium
                          ? AppConstants.positiveColor
                          : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    subscriptionService.isPremium
                        ? 'Transações ilimitadas + PDF'
                        : 'Até 10 transações',
                  ),
                  trailing: subscriptionService.isPremium
                      ? const Icon(
                          Icons.check_circle,
                          color: AppConstants.positiveColor,
                        )
                      : TextButton(
                          onPressed: () => _showUpgradeDialog(context),
                          child: const Text('Upgrade'),
                        ),
                ),
                if (!subscriptionService.isPremium) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: UpgradePromptWidget(
                      subscriptionService: subscriptionService,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Preferências
          _buildSectionHeader('Preferências'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Idioma
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text(
                    'Idioma',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _selectedLanguage == 'pt' ? 'Português' : 'English',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: const [
                      DropdownMenuItem(
                        value: 'pt',
                        child: Text(
                          'Português',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(
                          'English',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF122118),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                        await _saveSetting('language', value);
                        // Call the language change callback
                        widget.onLanguageChange?.call(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Idioma alterado para ${value == 'pt' ? 'Português' : 'English'}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const Divider(),

                // Moeda
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text(
                    'Moeda',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _currencies[_selectedCurrency] ?? 'Real (R\$)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedCurrency,
                    items: _currencies.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF122118),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() => _selectedCurrency = value);
                        await _saveSetting('currency', value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Moeda alterada para ${_currencies[value]}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const Divider(),

                // Tema
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text(
                    'Tema',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _getThemeDisplayName(_selectedTheme),
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedTheme,
                    items: const [
                      DropdownMenuItem(
                        value: 'auto',
                        child: Text(
                          'Automático (Verde)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text(
                          'Escuro',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'light',
                        child: Text(
                          'Claro',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF122118),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() => _selectedTheme = value);
                        await _saveSetting('theme', value);

                        // Update theme using provider
                        final themeNotifier = ref.read(
                          theme_provider.themeProvider.notifier,
                        );
                        theme_provider.AppTheme newTheme;
                        switch (value) {
                          case 'light':
                            newTheme = theme_provider.AppTheme.light;
                            break;
                          case 'dark':
                            newTheme = theme_provider.AppTheme.dark;
                            break;
                          case 'auto':
                          default:
                            newTheme = theme_provider.AppTheme.auto;
                            break;
                        }
                        await themeNotifier.setTheme(newTheme);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tema alterado para ${_getThemeDisplayName(value)}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Voz
          _buildSectionHeader('Entrada por Voz'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mic),
                  title: const Text('Tutorial de Voz'),
                  subtitle: const Text('Como usar comandos de voz'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showVoiceTutorial(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Testar Reconhecimento'),
                  subtitle: const Text('Teste o reconhecimento de voz'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _showVoiceTestDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Dados
          _buildSectionHeader('Dados'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Exportar Dados'),
                  subtitle: const Text('Salvar backup das transações'),
                  trailing: const Icon(Icons.download),
                  onTap: () => _exportData(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Importar Dados'),
                  subtitle: const Text('Restaurar backup'),
                  trailing: const Icon(Icons.upload),
                  onTap: () => _importData(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: AppConstants.alertColor,
                  ),
                  title: const Text('Limpar Todos os Dados'),
                  subtitle: const Text('Remover todas as transações'),
                  trailing: const Icon(
                    Icons.warning,
                    color: AppConstants.alertColor,
                  ),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Sobre
          _buildSectionHeader('Sobre'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Versão'),
                  subtitle: const Text('QuickBudget v1.0.0'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Ajuda'),
                  subtitle: const Text('FAQ e suporte'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _launchURL('https://quickbudget.com/help'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacidade'),
                  subtitle: const Text('Política de privacidade'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _launchURL('https://quickbudget.com/privacy'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Termos de Uso'),
                  subtitle: const Text('Leia os termos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _launchURL('https://quickbudget.com/terms'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Escuro';
      case 'auto':
      default:
        return 'Automático (Verde)';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade para Premium'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Desbloqueie recursos premium:'),
            SizedBox(height: 16),
            Text('• Transações ilimitadas'),
            Text('• Exportação em PDF'),
            Text('• Sem anúncios'),
            Text('• Suporte prioritário'),
            SizedBox(height: 16),
            Text('Preço: US\$ 4,99 (compra única)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement in-app purchase
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compra premium em breve!')),
              );
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Necessário'),
        content: const Text(
          'A mudança de idioma requer que o aplicativo seja reiniciado. '
          'Deseja reiniciar agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement app restart
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reinicie o aplicativo manualmente'),
                ),
              );
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _showVoiceTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF38E07B),
        title: Text(
          'Tutorial de Voz',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exemplos de comandos de voz:',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              '• "${_selectedLanguage == 'pt' ? 'vinte mercado' : 'twenty groceries'}" → ${_selectedCurrency == 'BRL' ? 'R\$20,00' : '\$20.00'} ${_selectedLanguage == 'pt' ? 'em Mercado' : 'in Groceries'}',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '• "${_selectedLanguage == 'pt' ? 'trinta quarenta quatro transporte' : 'thirty forty four transportation'}" → ${_selectedCurrency == 'BRL' ? 'R\$30,44' : '\$30.44'} ${_selectedLanguage == 'pt' ? 'em Transporte' : 'in Transportation'}',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '• "${_selectedLanguage == 'pt' ? 'cinquenta lazer' : 'fifty entertainment'}" → ${_selectedCurrency == 'BRL' ? 'R\$50,00' : '\$50.00'} ${_selectedLanguage == 'pt' ? 'em Lazer' : 'in Entertainment'}',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedLanguage == 'pt'
                  ? 'Diga o valor seguido da categoria.'
                  : 'Say the amount followed by the category.',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _selectedLanguage == 'pt' ? 'Entendi' : 'Understood',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showVoiceTestDialog(BuildContext context) {
    String testResult = '';
    bool isTesting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            _selectedLanguage == 'pt' ? 'Teste de Voz' : 'Voice Test',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedLanguage == 'pt'
                    ? 'Clique em "Testar" e diga algo em português'
                    : 'Click "Test" and say something in English',
              ),
              const SizedBox(height: 16),
              if (isTesting)
                const CircularProgressIndicator()
              else if (testResult.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"$testResult"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                _selectedLanguage == 'pt'
                    ? 'Exemplo: "vinte reais mercado"'
                    : 'Example: "twenty dollars groceries"',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_selectedLanguage == 'pt' ? 'Fechar' : 'Close'),
            ),
            ElevatedButton(
              onPressed: isTesting
                  ? null
                  : () async {
                      setState(() {
                        isTesting = true;
                        testResult = '';
                      });

                      try {
                        // TODO: Implement actual voice test
                        // For now, simulate a test result
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          isTesting = false;
                          testResult = _selectedLanguage == 'pt'
                              ? 'Teste de reconhecimento funcionando!'
                              : 'Voice recognition test working!';
                        });
                      } catch (e) {
                        setState(() {
                          isTesting = false;
                          testResult = _selectedLanguage == 'pt'
                              ? 'Erro no teste: $e'
                              : 'Test error: $e';
                        });
                      }
                    },
              child: Text(_selectedLanguage == 'pt' ? 'Testar' : 'Test'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) async {
    try {
      final dataExportService = ref.read(dataExportServiceProvider);

      // Show export options dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            _selectedLanguage == 'pt' ? 'Exportar Dados' : 'Export Data',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedLanguage == 'pt'
                    ? 'Escolha o formato de exportação:'
                    : 'Choose export format:',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await dataExportService.exportDataToPDF(
                        currency: _selectedCurrency,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await dataExportService.exportDataToJSON();
                    },
                    icon: const Icon(Icons.data_object),
                    label: const Text('JSON'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_selectedLanguage == 'pt' ? 'Cancelar' : 'Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'pt'
                ? 'Erro ao exportar dados: $e'
                : 'Error exporting data: $e',
          ),
        ),
      );
    }
  }

  void _importData(BuildContext context) {
    // TODO: Implement data import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedLanguage == 'pt'
              ? 'Funcionalidade de importação em desenvolvimento'
              : 'Import functionality under development',
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _selectedLanguage == 'pt'
              ? 'Limpar Todos os Dados'
              : 'Clear All Data',
        ),
        content: Text(
          _selectedLanguage == 'pt'
              ? 'Esta ação irá remover todas as transações permanentemente. Esta ação não pode ser desfeita. Deseja continuar?'
              : 'This action will permanently remove all transactions. This action cannot be undone. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_selectedLanguage == 'pt' ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final transactionService = ref.read(transactionServiceProvider);
                await transactionService.clearAllTransactions();

                // Also clear settings
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _selectedLanguage == 'pt'
                          ? 'Dados removidos com sucesso'
                          : 'Data cleared successfully',
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _selectedLanguage == 'pt'
                          ? 'Erro ao limpar dados: $e'
                          : 'Error clearing data: $e',
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.alertColor,
            ),
            child: Text(_selectedLanguage == 'pt' ? 'Limpar' : 'Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'pt'
                ? 'Não foi possível abrir o link'
                : 'Could not open link',
          ),
        ),
      );
    }
  }
}
