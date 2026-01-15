import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class QuickStudyButton extends StatelessWidget {
  final UserData userData;
  final bool isDark;
  final VoidCallback onQuickStudy;

  const QuickStudyButton({
    super.key,
    required this.userData,
    required this.isDark,
    required this.onQuickStudy,
  });

  @override
  Widget build(BuildContext context) {
    final hasCards = userData.totalCards > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.defaultPadding,
        20,
        AppStyles.defaultPadding,
        AppStyles.defaultPadding,
      ),
      child: Opacity(
        opacity: hasCards ? 1.0 : 0.72,
        child: InkWell(
          onTap: onQuickStudy,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? AppColors.quickStudyGradientDark
                    : AppColors.quickStudyGradientLight,
              ),
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 24),
                const SizedBox(width: AppStyles.sectionSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start quick learning session',
                        style: AppStyles.quickStudyTitle.copyWith(
                          fontSize: 15,
                          height: 1.25,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        !hasCards
                            ? 'Add cards to a deck to begin'
                            : userData.dueCardsCount > 0
                                ? '${userData.dueCardsCount} cards ready'
                                : 'Review all cards',
                        style: AppStyles.quickStudySubtitle,
                      ),
                    ],
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
