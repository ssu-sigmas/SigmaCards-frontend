import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../widgets/home/decks_section.dart';
import '../widgets/home/decks_tab_header.dart';

/// Вкладка «Колоды» — полный список без дублирования логики.
class DecksTabScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onCreateDeck;
  final Function(Deck) onEditDeck;
  final Function(Deck) onStudyDeck;
  final Function(String) onDeleteDeck;
  final bool isLoadingDecks;

  const DecksTabScreen({
    super.key,
    required this.userData,
    required this.onCreateDeck,
    required this.onEditDeck,
    required this.onStudyDeck,
    required this.onDeleteDeck,
    this.isLoadingDecks = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecksTabHeader(
              isDark: isDark,
              deckCount: userData.decks.length,
              totalCards: userData.totalCards,
              onCreateDeck: onCreateDeck,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 12, bottom: 28),
                  child: DecksSection(
                    userData: userData,
                    isDark: isDark,
                    onCreateDeck: onCreateDeck,
                    onEditDeck: onEditDeck,
                    onStudyDeck: onStudyDeck,
                    onDeleteDeck: onDeleteDeck,
                    showSectionTitle: false,
                    isLoading: isLoadingDecks,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
