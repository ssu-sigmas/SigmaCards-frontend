import 'dart:math';
import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/due_card.dart';
import '../models/enums.dart';
import '../models/card_with_deck.dart';
import '../services/api_service.dart';
import '../theme/app_styles.dart';
import '../theme/app_colors.dart';

class QuickStudySessionScreen extends StatefulWidget {
  final List<Deck> decks;
  final void Function(List<Deck> updatedDecks) onComplete;
  final VoidCallback onBack;

  const QuickStudySessionScreen({
    super.key,
    required this.decks,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<QuickStudySessionScreen> createState() => _QuickStudySessionScreenState();
}

enum _Difficulty { again, hard, good, easy }

class _QuickStudySessionScreenState extends State<QuickStudySessionScreen> {
  late List<CardWithDeck> _studyCards;
  late List<Deck> _updatedDecks;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _completed = 0;
  DateTime? _cardStartTime; // Для отслеживания времени ответа

  @override
  void initState() {
    super.initState();
    _updatedDecks = List.from(widget.decks);
    _loadStudyCards();
  }

  Future<void> _loadStudyCards() async {
    final cards = await _prepareStudyCards();
    if (mounted) {
      setState(() {
        _studyCards = cards;
      });
    }
  }

  Future<List<CardWithDeck>> _prepareStudyCards() async {
    final allDueCards = <CardWithDeck>[];

    // Если пользователь авторизован, загружаем due cards с сервера
    if (await ApiService.isAuthenticated()) {
      try {
        // Загружаем due cards для всех колод или конкретной колоды
        final result = await ApiService.getDueCards(limit: 100);
        
        if (result['success'] == true) {
          final cardsData = result['cards'] as List;
          final dueCards = cardsData
              .map((cardJson) => DueCard.fromJson(cardJson as Map<String, dynamic>))
              .toList();
          
          // Находим колоды для каждой карточки
          for (final dueCard in dueCards) {
            // Ищем колоду по cardId в загруженных карточках
            Deck? foundDeck;
            for (final deck in widget.decks) {
              if (deck.cards?.any((c) => c.id == dueCard.cardId) ?? false) {
                foundDeck = deck;
                break;
              }
            }
            
            // Если не нашли, используем первую колоду как fallback
            final deck = foundDeck ?? widget.decks.first;
            
            // Конвертируем DueCard в Flashcard для совместимости с CardWithDeck
            final flashcard = Flashcard(
              id: dueCard.cardId,
              deckId: deck.id,
              cardType: CardType.keyTerms, // По умолчанию
              content: dueCard.content,
              position: 0,
              isSuspended: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            allDueCards.add(CardWithDeck(
              card: flashcard,
              deckId: deck.id,
              deckName: deck.title,
              userCardId: dueCard.userCardId, // Сохраняем userCardId для отправки оценок
            ));
          }
        }
      } catch (e) {
        // Ошибка загрузки - используем локальные карточки
      }
    }
    
    // Если due cards не загружены или пользователь не авторизован, используем локальные карточки
    if (allDueCards.isEmpty) {
      for (final deck in widget.decks) {
        final cards = deck.cards ?? [];
        for (final card in cards) {
          allDueCards.add(CardWithDeck(
            card: card,
            deckId: deck.id,
            deckName: deck.title,
          ));
        }
      }
    }

    // Перемешиваем карточки
    final random = Random();
    allDueCards.shuffle(random);
    
    return allDueCards;
  }

  CardWithDeck? get _current => 
      _currentIndex < _studyCards.length ? _studyCards[_currentIndex] : null;

  void _flip() {
    setState(() {
      _isFlipped = !_isFlipped;
      if (!_isFlipped && _cardStartTime == null) {
        // Начинаем отслеживать время, когда карточка перевернута
        _cardStartTime = DateTime.now();
      }
    });
  }

  Future<void> _handleDifficulty(_Difficulty d) async {
    if (_current == null) return;
    
    final cardWithDeck = _current!;
    final rating = _difficultyToRating(d);
    
    // Вычисляем время ответа
    final durationMs = _cardStartTime != null
        ? DateTime.now().difference(_cardStartTime!).inMilliseconds
        : 0;

    // Если есть userCardId, отправляем оценку на сервер
    if (cardWithDeck.userCardId != null && 
        cardWithDeck.userCardId!.isNotEmpty && 
        await ApiService.isAuthenticated()) {
      try {
        final result = await ApiService.submitReview(
          userCardId: cardWithDeck.userCardId!,
          rating: rating,
          durationMs: durationMs,
        );

        if (result['success'] == true) {
          // Оценка успешно отправлена, FSRS обновлен на сервере
        } else {
          // Ошибка отправки - показываем сообщение, но продолжаем
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'Ошибка отправки оценки'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        // Ошибка сети - продолжаем локально
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сети: ${e.toString()}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }

    // Обновляем локальное состояние (для совместимости)
    final updatedCard = _calculateNextReview(cardWithDeck.card, d);

    // Обновляем колоду, которая содержит эту карточку
    _updatedDecks = _updatedDecks.map((deck) {
      if (deck.id == _current!.deckId) {
        final currentCards = deck.cards ?? [];
        final updatedCards = currentCards.map((c) =>
          c.id == updatedCard.id ? updatedCard : c
        ).toList();
        
        return deck.copyWith(
          cards: updatedCards,
          updatedAt: DateTime.now(),
        );
      }
      return deck;
    }).toList();

    // Обновляем карточку в списке для отображения
    final updatedCardWithDeck = CardWithDeck(
      card: updatedCard,
      deckId: cardWithDeck.deckId,
      deckName: cardWithDeck.deckName,
      userCardId: cardWithDeck.userCardId,
    );
    _studyCards[_currentIndex] = updatedCardWithDeck;

    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex += 1;
        _isFlipped = false;
        _completed += 1;
        _cardStartTime = null;
      });
    } else {
      // Сессия завершена
      setState(() {
        _completed += 1;
      });
      
      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Отлично! Вы повторили ${_studyCards.length} карточек.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Задержка перед возвратом, как в TypeScript версии
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          widget.onComplete(_updatedDecks);
          Navigator.of(context).pop();
        }
      });
    }
  }

  int _difficultyToRating(_Difficulty d) {
    switch (d) {
      case _Difficulty.again:
        return 1;
      case _Difficulty.hard:
        return 2;
      case _Difficulty.good:
        return 3;
      case _Difficulty.easy:
        return 4;
    }
  }

  Flashcard _calculateNextReview(Flashcard card, _Difficulty d) {
    // Локальная заглушка для совместимости (FSRS обрабатывается на сервере)
    return card.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_current == null || _studyCards.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          title: const Text('Быстрое повторение'),
        ),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Все карточки изучены!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нет карточек для повторения прямо сейчас.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onBack,
                    child: const Text('Вернуться на главную'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final progress = _studyCards.isEmpty ? 0.0 : _completed / _studyCards.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Быстрое повторение'),
            Text(
              '$_completed / ${_studyCards.length} карточек',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress == 0 ? null : progress,
              minHeight: 4,
            ),
            const SizedBox(height: 16),
            // Название колоды
            Text(
              'из колоды: ${_current!.deckName}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            // Карточка
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isFlipped
                        ? const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isFlipped
                        ? null
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isFlipped ? 'Ответ' : 'Вопрос',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isFlipped
                                ? Colors.white70
                                : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isFlipped ? _current!.card.back : _current!.card.front,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _isFlipped
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Нажмите, чтобы ${_isFlipped ? 'скрыть' : 'увидеть'} ответ',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isFlipped
                                ? Colors.white70
                                : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопки сложности
            if (_isFlipped)
              Column(
                children: [
                  Text(
                    'Насколько хорошо вы знали это?',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.again),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF9A9A)),
                            foregroundColor: const Color(0xFFD32F2F),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 18),
                              SizedBox(width: 4),
                              Text('Снова'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.hard),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFCC80)),
                            foregroundColor: const Color(0xFFF57C00),
                          ),
                          child: const Text('Трудно'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.good),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Хорошо'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.easy),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Легко'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                'Нажмите на карточку, чтобы увидеть ответ',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
}






