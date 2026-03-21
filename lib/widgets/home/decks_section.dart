import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../models/deck.dart';
import '../../widgets/deck_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class DecksSection extends StatelessWidget {
  final UserData userData;
  final bool isDark;
  final VoidCallback onCreateDeck;
  final Function(Deck) onEditDeck;
  final Function(Deck) onStudyDeck;
  final Function(String) onDeleteDeck;
  final bool showSectionTitle;

  const DecksSection({
    super.key,
    required this.userData,
    required this.isDark,
    required this.onCreateDeck,
    required this.onEditDeck,
    required this.onStudyDeck,
    required this.onDeleteDeck,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSectionTitle) ...[
            Text(
              'Мои колоды',
              style: AppStyles.sectionTitle(isDark),
            ),
            const SizedBox(height: AppStyles.sectionSpacing),
          ],
          userData.decks.isEmpty
              ? _buildEmptyState(context, scheme)
              : _buildDecksList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  AppColors.darkCard,
                ]
              : [
                  Colors.white,
                  scheme.primaryContainer.withValues(alpha: 0.22),
                ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 44,
                color: isDark ? scheme.primary.withValues(alpha: 0.9) : scheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Пока нет колод',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте первую колоду и добавьте карточки — так удобнее повторять материал.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateDeck,
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text('Создать колоду'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecksList(BuildContext context) {
    return Column(
      children: userData.decks.map((deck) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppStyles.cardSpacing),
          child: DeckCard(
            deck: deck,
            onEdit: () => onEditDeck(deck),
            onStudy: () => onStudyDeck(deck),
            onDelete: () => _showDeleteDialog(context, deck),
          ),
        );
      }).toList(),
    );
  }

  void _showDeleteDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить колоду?'),
        content: Text(
          'Колода «${deck.title}» и все её карточки будут удалены. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteDeck(deck.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
