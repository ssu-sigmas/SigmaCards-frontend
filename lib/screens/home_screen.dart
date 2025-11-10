import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../widgets/home/header_section.dart';
import '../widgets/home/quick_study_button.dart';
import '../widgets/home/quick_actions_section.dart';
import '../widgets/home/decks_section.dart';

class HomeScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onCreateDeck;
  final Function(Deck) onStudyDeck;
  final VoidCallback onQuickStudy;
  final Function(String) onDeleteDeck;
  final VoidCallback onAIImport;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.userData,
    required this.onCreateDeck,
    required this.onStudyDeck,
    required this.onQuickStudy,
    required this.onDeleteDeck,
    required this.onAIImport,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderSection(
                userData: userData,
                isDark: isDark,
                onToggleTheme: onToggleTheme,
              ),
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
              const SizedBox(height: 24),
              DecksSection(
                userData: userData,
                isDark: isDark,
                onCreateDeck: onCreateDeck,
                onStudyDeck: onStudyDeck,
                onDeleteDeck: onDeleteDeck,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
