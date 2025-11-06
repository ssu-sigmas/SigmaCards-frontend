import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/user_data.dart';
import 'models/deck.dart';
import 'models/flashcard.dart';

void main() {
  runApp(const SigmaCardsApp());
}

class SigmaCardsApp extends StatefulWidget {
  const SigmaCardsApp({super.key});

  @override
  State<SigmaCardsApp> createState() => _SigmaCardsAppState();
}

class _SigmaCardsAppState extends State<SigmaCardsApp> {
  UserData _userData = UserData(
    hasCompletedOnboarding: true,
    decks: [
      Deck(
        id: 'demo-1',
        name: 'Spanish Basics',
        description: 'Essential Spanish vocabulary',
        color: 'bg-blue-500',
        createdAt: DateTime.now(),
        cards: [
          Flashcard(
            id: 'card-1',
            front: 'Hello',
            back: 'Hola',
            nextReview: DateTime.now(),
            interval: 1,
            easeFactor: 2.5,
            repetitions: 0,
          ),
          Flashcard(
            id: 'card-2',
            front: 'Goodbye',
            back: 'Adiós',
            nextReview: DateTime.now(),
            interval: 1,
            easeFactor: 2.5,
            repetitions: 0,
          ),
          Flashcard(
            id: 'card-3',
            front: 'Thank you',
            back: 'Gracias',
            nextReview: DateTime.now(),
            interval: 1,
            easeFactor: 2.5,
            repetitions: 0,
          ),
        ],
      ),
    ],
    studyStreak: 5,
    theme: AppTheme.light,
  );

  void _toggleTheme() {
    setState(() {
      _userData = _userData.copyWith(
        theme: _userData.theme == AppTheme.light 
            ? AppTheme.dark 
            : AppTheme.light,
      );
    });
  }

  void _createDeck() {
    // Placeholder for create deck functionality
    print('Create deck');
  }

  void _studyDeck(Deck deck) {
    // Placeholder for study deck functionality
    print('Study deck: ${deck.name}');
  }

  void _quickStudy() {
    // Placeholder for quick study functionality
    print('Quick study');
  }

  void _deleteDeck(String deckId) {
    setState(() {
      _userData = _userData.copyWith(
        decks: _userData.decks.where((d) => d.id != deckId).toList(),
      );
    });
  }

  void _aiImport() {
    // Placeholder for AI import functionality
    print('AI Import');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SigmaCards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _userData.theme == AppTheme.light 
          ? ThemeMode.light 
          : ThemeMode.dark,
      home: HomeScreen(
        userData: _userData,
        onCreateDeck: _createDeck,
        onStudyDeck: _studyDeck,
        onQuickStudy: _quickStudy,
        onDeleteDeck: _deleteDeck,
        onAIImport: _aiImport,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
