import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppConstants.borderColor, width: 1),
        ),
      ),
      child: BottomAppBar(
        color: AppConstants.secondaryBackground,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              Icons.home,
              AppLocalizations.of(context)?.home ?? 'Home',
            ),
            _buildNavItem(
              1,
              Icons.history,
              AppLocalizations.of(context)?.history ?? 'Histórico',
            ),
            _buildNavItem(
              2,
              Icons.settings,
              AppLocalizations.of(context)?.settings ?? 'Configurações',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppConstants.primaryColor
                    : AppConstants.iconActive,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppConstants.textColor
                      : AppConstants.iconActive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
