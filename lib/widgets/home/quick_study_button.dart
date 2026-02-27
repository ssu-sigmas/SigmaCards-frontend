import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/ru_plural.dart';

class QuickStudyButton extends StatelessWidget {
  final UserData userData;
  final bool isDark;
  final VoidCallback onQuickStudy;
  final int? dueCardsCount;

  const QuickStudyButton({
    super.key,
    required this.userData,
    required this.isDark,
    required this.onQuickStudy,
    this.dueCardsCount,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Повторить на сегодня',
                        style: AppStyles.quickStudyTitle.copyWith(
                          fontSize: 16,
                          height: 1.25,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        !hasCards
                            ? 'Добавьте карточки в колоду'
                            : ruCardCountLabel(dueCardsCount ?? 0),
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
