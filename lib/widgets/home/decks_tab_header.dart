import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/ru_plural.dart';

/// Шапка вкладки «Мои колоды» — градиент как на главной.
class DecksTabHeader extends StatelessWidget {
  final bool isDark;
  final int deckCount;
  final int totalCards;
  final VoidCallback onCreateDeck;

  const DecksTabHeader({
    super.key,
    required this.isDark,
    required this.deckCount,
    required this.totalCards,
    required this.onCreateDeck,
  });

  static String _deckWord(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'колод';
    if (m10 == 1) return 'колода';
    if (m10 >= 2 && m10 <= 4) return 'колоды';
    return 'колод';
  }

  String get _subtitle {
    if (deckCount == 0) {
      return 'Создавайте колоды и наполняйте их карточками';
    }
    return '$deckCount ${_deckWord(deckCount)} · ${ruCardCountLabel(totalCards)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppStyles.defaultPadding,
            22,
            AppStyles.defaultPadding,
            22,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Мои колоды',
                      style: AppStyles.headerTitle,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subtitle,
                      style: AppStyles.headerSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    onPressed: onCreateDeck,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    tooltip: 'Новая колода',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
