import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../sigma_mascot.dart';

class HeaderSection extends StatelessWidget {
  final UserData userData;
  final bool isDark;
  final int dueCount;

  const HeaderSection({
    super.key,
    required this.userData,
    required this.isDark,
    this.dueCount = 0,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  String get _greetingWithName {
    final name = userData.username;
    if (name == null || name.isEmpty) return _greeting;
    final firstName = name.split(' ').first;
    final capitalized =
        firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
    return '$_greeting, $capitalized!';
  }

  String get _subtitle {
    if (dueCount > 0) {
      return 'Сегодня к повторению: $dueCount ${_cardWord(dueCount)}';
    }
    if (userData.studyStreak >= 7) {
      return '${userData.studyStreak} дней подряд — впечатляет!';
    }
    if (userData.studyStreak > 0) {
      return 'Серия ${userData.studyStreak} ${_dayWord(userData.studyStreak)} — так держать!';
    }
    if (userData.decks.isEmpty) {
      return 'Создайте первую колоду и начните учиться';
    }
    return 'Все карточки повторены — отличная работа!';
  }

  static String _cardWord(int n) {
    final m10 = n % 10, m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'карточек';
    if (m10 == 1) return 'карточка';
    if (m10 >= 2 && m10 <= 4) return 'карточки';
    return 'карточек';
  }

  static String _dayWord(int n) {
    final m10 = n % 10, m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'дней';
    if (m10 == 1) return 'день';
    if (m10 >= 2 && m10 <= 4) return 'дня';
    return 'дней';
  }

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
              if (userData.studyStreak > 0)
                _StreakBadge(streak: userData.studyStreak),
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
                    Text(
                      _greetingWithName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
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
                      _subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
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
                child: const SigmaMascot(size: 110),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
