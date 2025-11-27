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
    });

    // Если пользователь авторизован, загружаем колоды с сервера
    if (_userData.isAuthenticated && await ApiService.isAuthenticated()) {
      await _loadDecksFromServer();
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDecksFromServer() async {
    try {
      final result = await ApiService.getUserDecks(limit: 100);
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        final decksData = result['decks'] as List;
        final decks = decksData
            .map((deckJson) => Deck.fromJson(deckJson as Map<String, dynamic>))
            .toList();
        
        setState(() {
          _userData = _userData.copyWith(decks: decks);
        });
        _persist();
      }
    } catch (e) {
      // Ошибка загрузки колод - используем локальные данные
      if (mounted) {
        final ctx = _navigatorKey.currentContext;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Не удалось загрузить колоды: ${e.toString()}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
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
          onSave: (deck) async {
            // Если пользователь авторизован, отправляем на сервер
            if (_userData.isAuthenticated && await ApiService.isAuthenticated()) {
              await _createDeckOnServer(deck);
            } else {
              // Локальное сохранение
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

  Future<void> _createDeckOnServer(Deck deck) async {
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
              Text('Создание колоды...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      final result = await ApiService.createDeck(
        title: deck.title,
        description: deck.description,
      );

      if (!mounted) return;

      // Убираем предыдущий snackbar
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
      }

      if (result['success'] == true) {
        // Создаем Deck из ответа сервера
        final deckData = result['data'] as Map<String, dynamic>;
        final createdDeck = Deck.fromJson(deckData);
        
        // Если есть карточки, создаем их отдельно
        if (deck.cards != null && deck.cards!.isNotEmpty) {
          // TODO: Создать карточки через API
          // Пока добавляем колоду без карточек
        }

        setState(() {
          _userData = _userData.copyWith(
            decks: [..._userData.decks, createdDeck],
          );
        });
        _persist();

        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Колода создана успешно'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Ошибка создания
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Ошибка создания колоды'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _deleteDeck(String deckId) async {
    // Если пользователь авторизован, удаляем через API
    if (_userData.isAuthenticated && await ApiService.isAuthenticated()) {
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
                Text('Удаление колоды...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final result = await ApiService.deleteDeck(deckId);

      if (!mounted) return;

      // Убираем предыдущий snackbar
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
      }

      if (result['success'] == true) {
        // Удаляем из локального состояния
        setState(() {
          _userData = _userData.copyWith(
            decks: _userData.decks.where((d) => d.id != deckId).toList(),
          );
        });
        _persist();

        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Колода удалена'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Ошибка удаления
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Ошибка удаления колоды'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      // Локальное удаление
      setState(() {
        _userData = _userData.copyWith(
          decks: _userData.decks.where((d) => d.id != deckId).toList(),
        );
      });
      _persist();
    }
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

  Future<void> _handleLogin(String email, String password) async {
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
              Text('Вход...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    // Вызываем API входа
    final result = await ApiService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    // Убираем предыдущий snackbar
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    }

    if (result['success'] == true) {
      // Получаем userId из сохраненных данных
      final userId = await ApiService.getUserId();
      
      // Успешный вход
      setState(() {
        _userData = _userData.copyWith(
          isAuthenticated: true,
          userId: userId,
        );
      });
      _persist();

      // Загружаем колоды с сервера
      await _loadDecksFromServer();

      if (!mounted) return;

      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Вход выполнен успешно'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Ошибка входа
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ошибка входа'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
      // Получаем userId из сохраненных данных
      final userId = await ApiService.getUserId();
      
      // Успешная регистрация
      setState(() {
        _userData = _userData.copyWith(
          isAuthenticated: true,
          userId: userId,
        );
      });
      _persist();

      // Загружаем колоды с сервера (для нового пользователя будет пустой список)
      await _loadDecksFromServer();

      if (!mounted) return;

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
