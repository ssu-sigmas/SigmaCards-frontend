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

  static const double _rowHeight = 52;

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
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCreateDeck,
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text('Create Deck'),
                    style: AppStyles.purpleButtonStyle.copyWith(
                      minimumSize: MaterialStateProperty.all(const Size(0, _rowHeight)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppStyles.sectionSpacing),
                Expanded(
                  child: _GradientImportButton(isDark: isDark, onTap: onAIImport),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientImportButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _GradientImportButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? AppColors.aiImportGradientDark
                  : AppColors.aiImportGradientLight,
            ),
          ),
          child: SizedBox(
            height: QuickActionsSection._rowHeight,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_rounded, size: 22, color: Colors.white),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Import Text',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
