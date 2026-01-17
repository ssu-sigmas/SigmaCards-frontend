import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../sigma_mascot.dart';

class HeaderSection extends StatelessWidget {
  final UserData userData;
  final bool isDark;

  const HeaderSection({
    super.key,
    required this.userData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? AppColors.headerGradientDark
              : AppColors.headerGradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppStyles.headerBorderRadius),
          bottomRight: Radius.circular(AppStyles.headerBorderRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppStyles.defaultPadding,
        12,
        AppStyles.defaultPadding,
        AppStyles.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'СигмаКарточки',
                  style: AppStyles.headerTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🔥',
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${userData.studyStreak}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _streakLabel(userData.studyStreak),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ученье — свет',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'В этом свете — сила разума и путь сквозь тьму неведения.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.35,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Transform.translate(
                offset: const Offset(-12, 0),
                child: const SigmaMascot(size: 118),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// «1 день подряд», «2 дня подряд», «5 дней подряд» и т.д.
  static String _streakLabel(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'дней подряд';
    if (m10 == 1) return 'день подряд';
    if (m10 >= 2 && m10 <= 4) return 'дня подряд';
    return 'дней подряд';
  }
}
