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
    if (userData.totalCards == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, color: Colors.white, size: 24),
              const SizedBox(width: AppStyles.sectionSpacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Learning', style: AppStyles.quickStudyTitle),
                  Text(
                    userData.dueCardsCount > 0
                        ? '${userData.dueCardsCount} cards ready'
                        : 'Review all cards',
                    style: AppStyles.quickStudySubtitle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
