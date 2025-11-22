import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/create_deck_screen.dart';
import 'screens/study_session_screen.dart';
import 'screens/quick_study_session_screen.dart';
import 'screens/import_text_screen.dart';
import 'models/user_data.dart';
import 'models/deck.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'widgets/create_deck/flashcards_editor.dart';

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
    isAuthenticated: false,
    hasCompletedOnboarding: false,
    decks: [],
    studyStreak: 0,
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

  void _createDeck({List<FlashcardDraft>? initialCards}) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => CreateDeckScreen(
          initialCards: initialCards,
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
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => StudySessionScreen(
          deck: deck,
          onComplete: (updatedDeck) {
            setState(() {
              _userData = _userData.copyWith(
                decks: _userData.decks.map((d) => d.id == updatedDeck.id ? updatedDeck : d).toList(),
              );
            });
            _persist();
          },
        ),
      ),
    );
  }

  void _quickStudy() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => QuickStudySessionScreen(
          decks: _userData.decks,
          onComplete: (updatedDecks) {
            setState(() {
              _userData = _userData.copyWith(decks: updatedDecks);
            });
            _persist();
          },
          onBack: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _deleteDeck(String deckId) {
    setState(() {
      _userData = _userData.copyWith(
        decks: _userData.decks.where((d) => d.id != deckId).toList(),
      );
    });
    _persist();
  }

  Future<void> _aiImport() async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    final importedDrafts = await navigator.push<List<FlashcardDraft>>(
      MaterialPageRoute(
        builder: (context) => const ImportTextScreen(),
      ),
    );

    if (importedDrafts == null || importedDrafts.isEmpty) {
      return;
    }

    _createDeck(initialCards: importedDrafts);
  }

  void _completeOnboarding() {
    setState(() {
      _userData = _userData.copyWith(
        hasCompletedOnboarding: true,
      );
    });
    _persist();
  }

  void _handleLogin(String email, String password) {
    // TODO: Реализовать реальную логику авторизации
    // Пока просто помечаем пользователя как авторизованного
    setState(() {
      _userData = _userData.copyWith(
        isAuthenticated: true,
      );
    });
    _persist();
    
    final ctx = _navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Вход выполнен успешно'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleRegister(String username, String email, String password) async {
    final ctx = _navigatorKey.currentContext;
    
    // Показываем индикатор загрузки
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Регистрация...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    // Вызываем API регистрации
    final result = await ApiService.register(
      username: username,
      email: email,
      password: password,
    );

    if (!mounted) return;

    // Убираем предыдущий snackbar
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    }

    if (result['success'] == true) {
      // Успешная регистрация
      setState(() {
        _userData = _userData.copyWith(
          isAuthenticated: true,
        );
      });
      _persist();

      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Регистрация выполнена успешно'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Ошибка регистрации
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ошибка регистрации'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
          : !_userData.isAuthenticated
              ? AuthScreen(
                  onLogin: _handleLogin,
                  onRegister: _handleRegister,
                )
              : _userData.hasCompletedOnboarding
                  ? HomeScreen(
                      userData: _userData,
                      onCreateDeck: () => _createDeck(),
                      onStudyDeck: _studyDeck,
                      onQuickStudy: _quickStudy,
                      onDeleteDeck: _deleteDeck,
                      onAIImport: _aiImport,
                      onToggleTheme: _toggleTheme,
                    )
                  : OnboardingScreen(
                      onComplete: _completeOnboarding,
                    ),
    );
  }
}
