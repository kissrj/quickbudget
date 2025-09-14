import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../services/subscription_service.dart';
import '../widgets/upgrade_prompt_widget.dart';
import '../main.dart'; // Import for subscriptionServiceProvider

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          onPressed: () {
                            // TODO: Show upgrade dialog
                          },
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
                  title: const Text('Idioma'),
                  subtitle: const Text('Português'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement language selection
                  },
                ),
                const Divider(),

                // Moeda
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Moeda'),
                  subtitle: const Text('Real (R\$)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement currency selection
                  },
                ),
                const Divider(),

                // Tema
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Tema'),
                  subtitle: const Text('Automático (claro/escuro)'),
                  trailing: const Icon(Icons.brightness_auto),
                  onTap: () {
                    // TODO: Implement theme selection
                  },
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
                  onTap: () {
                    _showVoiceTutorial(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Testar Reconhecimento'),
                  subtitle: const Text('Teste o reconhecimento de voz'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    // TODO: Implement voice test
                  },
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
                  onTap: () {
                    // TODO: Implement data export
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Importar Dados'),
                  subtitle: const Text('Restaurar backup'),
                  trailing: const Icon(Icons.upload),
                  onTap: () {
                    // TODO: Implement data import
                  },
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
                  onTap: () {
                    _showClearDataDialog(context);
                  },
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
                  onTap: () {
                    // TODO: Navigate to help screen
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacidade'),
                  subtitle: const Text('Política de privacidade'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Termos de Uso'),
                  subtitle: const Text('Leia os termos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to terms of service
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
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
              '• "20 mercado" → R\$20,00 em Mercado',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '• "30 44 transporte" → R\$30,44 em Transporte',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '• "50 lazer" → R\$50,00 em Lazer',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              'Diga o valor seguido da categoria.',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendi',
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

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Todos os Dados'),
        content: const Text(
          'Esta ação irá remover todas as transações permanentemente. '
          'Esta ação não pode ser desfeita. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear all data
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados removidos com sucesso')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.alertColor,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
