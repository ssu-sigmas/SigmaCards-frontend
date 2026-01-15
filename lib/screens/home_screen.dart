import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../widgets/home/header_section.dart';
import '../widgets/home/quick_study_button.dart';
import '../widgets/home/quick_actions_section.dart';
import '../widgets/sigma_mascot.dart';

/// Контент вкладки «Главная» (без собственного Scaffold — его даёт [MainShellScreen]).
class HomeScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onCreateDeck;
  final Function(Deck) onEditDeck;
  final Function(Deck) onStudyDeck;
  final VoidCallback onQuickStudy;
  final Function(String) onDeleteDeck;
  final VoidCallback onAIImport;
  final VoidCallback onOpenDecksTab;

  const HomeScreen({
    super.key,
    required this.userData,
    required this.onCreateDeck,
    required this.onEditDeck,
    required this.onStudyDeck,
    required this.onQuickStudy,
    required this.onDeleteDeck,
    required this.onAIImport,
    required this.onOpenDecksTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SizedBox.expand(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeaderSection(
                        userData: userData,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                      QuickStudyButton(
                        userData: userData,
                        isDark: isDark,
                        onQuickStudy: onQuickStudy,
                      ),
                      QuickActionsSection(
                        isDark: isDark,
                        onCreateDeck: onCreateDeck,
                        onAIImport: onAIImport,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Material(
                          color: scheme.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.35 : 0.65,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: onOpenDecksTab,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(Icons.library_books_rounded, color: scheme.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Мои колоды',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          userData.decks.isEmpty
                                              ? 'Пока пусто — создайте первую'
                                              : '${userData.decks.length} ${_decksWord(userData.decks.length)}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: scheme.outline),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ученье — свет',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'В этом свете — сила разума и путь сквозь тьму неведения.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SigmaMascot(size: 140),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _decksWord(int n) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return 'колод';
    if (m10 == 1) return 'колода';
    if (m10 >= 2 && m10 <= 4) return 'колоды';
    return 'колод';
  }
}
