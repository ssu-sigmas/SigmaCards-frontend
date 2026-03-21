import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/deck.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/home/header_section.dart';
import '../widgets/home/quick_study_button.dart';
import '../widgets/home/quick_actions_section.dart';
import '../widgets/home/streak_heatmap_section.dart';
import '../utils/study_activity.dart';

/// Контент вкладки «Главная» (без собственного Scaffold — его даёт [MainShellScreen]).
class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dueCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDueCount();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userData.decks != widget.userData.decks) {
      _loadDueCount();
    }
  }

  Future<void> _loadDueCount() async {
    if (!await ApiService.isAuthenticated()) return;
    final result = await ApiService.getDueCards(limit: 100);
    if (!mounted) return;
    if (result['success'] == true) {
      final cards = result['cards'] as List;
      setState(() => _dueCount = cards.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SizedBox.expand(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeaderSection(
                        userData: widget.userData,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                      QuickStudyButton(
                        userData: widget.userData,
                        isDark: isDark,
                        onQuickStudy: widget.onQuickStudy,
                        dueCardsCount: _dueCount,
                      ),
                      QuickActionsSection(
                        isDark: isDark,
                        onCreateDeck: widget.onCreateDeck,
                        onAIImport: widget.onAIImport,
                      ),
                      if (widget.userData.decks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Material(
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: isDark ? 0.35 : 0.65,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: widget.onOpenDecksTab,
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
                                            '${widget.userData.decks.length} ${_decksWord(widget.userData.decks.length)}',
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
                      if (widget.userData.decks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          child: FilledButton.icon(
                            onPressed: widget.onCreateDeck,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Создать первую колоду'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      if (widget.userData.dailyReviewCounts.isNotEmpty)
                        StreakHeatmapSection(
                          dailyReviewCounts: widget.userData.dailyReviewCounts,
                          longestStreak:
                              StudyActivity.computeLongestStreak(widget.userData.dailyReviewCounts),
                          isDark: isDark,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
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
