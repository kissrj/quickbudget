import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/subscription_service.dart';

class UpgradePromptWidget extends StatelessWidget {
  final SubscriptionService subscriptionService;

  const UpgradePromptWidget({Key? key, required this.subscriptionService})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!subscriptionService.shouldShowUpgradePrompt()) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Upgrade para Premium',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Dismiss prompt (for now, just hide)
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subscriptionService.getUpgradeMessage(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'US\$ ${AppConstants.premiumPrice}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppConstants.premiumCurrency,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to purchase flow
                      _showPurchaseDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upgrade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Premium features list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem('✅ Transações ilimitadas'),
                _buildFeatureItem('✅ Exportação em PDF'),
                _buildFeatureItem('✅ Sem anúncios'),
                _buildFeatureItem('✅ Suporte prioritário'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        feature,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Upgrade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade para Premium por US\$ ${AppConstants.premiumPrice}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recursos incluídos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Transações ilimitadas'),
              const Text('• Exportação em PDF'),
              const Text('• Sem anúncios'),
              const Text('• Suporte prioritário'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement actual purchase flow
                subscriptionService.simulatePremiumPurchase();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upgrade realizado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
