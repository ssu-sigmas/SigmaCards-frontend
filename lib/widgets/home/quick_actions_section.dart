import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class QuickActionsSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCreateDeck;
  final VoidCallback onAIImport;

  const QuickActionsSection({
    super.key,
    required this.isDark,
    required this.onCreateDeck,
    required this.onAIImport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppStyles.sectionSpacing),
          Text(
            'Quick Actions',
            style: AppStyles.sectionTitle(isDark),
          ),
          const SizedBox(height: AppStyles.sectionSpacing),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCreateDeck,
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text('Create Deck'),
                  style: AppStyles.purpleButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppStyles.sectionSpacing),
              Expanded(
                child: _buildAIImportButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIImportButton() {
    return InkWell(
      onTap: onAIImport,
      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? AppColors.aiImportGradientDark
                : AppColors.aiImportGradientLight,
          ),
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 24, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Import Text',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
