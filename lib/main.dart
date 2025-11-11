import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/create_deck_screen.dart';
import 'models/user_data.dart';
import 'models/deck.dart';
import 'models/flashcard.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const SigmaCardsApp());
}

class SigmaCardsApp extends StatefulWidget {
  const SigmaCardsApp({super.key});

  @override
  State<SigmaCardsApp> createState() => _SigmaCardsAppState();
}

class _SigmaCardsAppState extends State<SigmaCardsApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final loaded = await StorageService.loadUserData();
    if (!mounted) return;
    setState(() {
      if (loaded != null) {
        _userData = loaded;
      }
      _isLoading = false;
    });
  }

  Future<void> _persist() => StorageService.saveUserData(_userData);

  void _toggleTheme() {
    setState(() {
      _userData = _userData.copyWith(
        theme: _userData.theme == AppTheme.light 
            ? AppTheme.dark 
            : AppTheme.light,
      );
    });
    _persist();
  }

  void _createDeck() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => CreateDeckScreen(
          onSave: (deck) {
            setState(() {
              _userData = _userData.copyWith(
                decks: [..._userData.decks, deck],
              );
            });
            _persist();
            final ctx = _navigatorKey.currentContext;
            if (ctx != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Deck created successfully')),
              );
            }
            _navigatorKey.currentState?.pop();
          },
          onCancel: () {
            _navigatorKey.currentState?.pop();
          },
        ),
      ),
    );
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
    _persist();
  }

  void _aiImport() {
    // Placeholder for AI import functionality
    print('AI Import');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : HomeScreen(
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
