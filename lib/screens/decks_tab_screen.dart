import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/deck.dart';
import '../widgets/home/decks_section.dart';

/// Вкладка «Колоды» — полный список без дублирования логики.
class DecksTabScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onCreateDeck;
  final Function(Deck) onEditDeck;
  final Function(Deck) onStudyDeck;
  final Function(String) onDeleteDeck;

  const DecksTabScreen({
    super.key,
    required this.userData,
    required this.onCreateDeck,
    required this.onEditDeck,
    required this.onStudyDeck,
    required this.onDeleteDeck,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои колоды'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: onCreateDeck,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Новая колода',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: DecksSection(
            userData: userData,
            isDark: isDark,
            onCreateDeck: onCreateDeck,
            onEditDeck: onEditDeck,
            onStudyDeck: onStudyDeck,
            onDeleteDeck: onDeleteDeck,
            showSectionTitle: false,
          ),
        ),
      ),
    );
  }
}
