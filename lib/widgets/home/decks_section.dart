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
  final Function(Deck) onStudyDeck;
  final Function(String) onDeleteDeck;

  const DecksSection({
    super.key,
    required this.userData,
    required this.isDark,
    required this.onCreateDeck,
    required this.onStudyDeck,
    required this.onDeleteDeck,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Decks',
            style: AppStyles.sectionTitle(isDark),
          ),
          const SizedBox(height: AppStyles.sectionSpacing),
          userData.decks.isEmpty
              ? _buildEmptyState(context)
              : _buildDecksList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.psychology,
              size: 48,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            const SizedBox(height: AppStyles.sectionSpacing),
            Text(
              'No decks yet',
              style: AppStyles.emptyStateTitle(isDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first deck to start learning',
              style: AppStyles.emptyStateSubtitle(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreateDeck,
              icon: const Icon(Icons.add),
              label: const Text('Create Deck'),
              style: AppStyles.purpleButtonStyle,
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
        title: const Text('Delete deck?'),
        content: Text(
          'This will permanently delete "${deck.name}" and all its cards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteDeck(deck.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
