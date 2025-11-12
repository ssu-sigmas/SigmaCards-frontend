import 'dart:math';
import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/card_with_deck.dart';
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

  @override
  void initState() {
    super.initState();
    _updatedDecks = List.from(widget.decks);
    _studyCards = _prepareStudyCards();
  }

  List<CardWithDeck> _prepareStudyCards() {
    final today = DateTime.now();
    final allDueCards = <CardWithDeck>[];

    // Собираем все due карточки из всех колод
    for (final deck in widget.decks) {
      final dueCards = deck.cards.where((card) =>
        card.nextReview.isBefore(today) || 
        card.nextReview.isAtSameMomentAs(today)
      ).toList();
      
      for (final card in dueCards) {
        allDueCards.add(CardWithDeck(
          card: card,
          deckId: deck.id,
          deckName: deck.name,
        ));
      }
    }

    // Если нет due карточек, берем все карточки
    if (allDueCards.isEmpty) {
      for (final deck in widget.decks) {
        for (final card in deck.cards) {
          allDueCards.add(CardWithDeck(
            card: card,
            deckId: deck.id,
            deckName: deck.name,
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

  void _flip() => setState(() => _isFlipped = !_isFlipped);

  void _handleDifficulty(_Difficulty d) {
    if (_current == null) return;
    
    final updatedCard = _calculateNextReview(_current!.card, d);

    // Обновляем колоду, которая содержит эту карточку
    _updatedDecks = _updatedDecks.map((deck) {
      if (deck.id == _current!.deckId) {
        final updatedCards = deck.cards.map((c) =>
          c.id == updatedCard.id ? updatedCard : c
        ).toList();
        
        return Deck(
          id: deck.id,
          name: deck.name,
          description: deck.description,
          cards: updatedCards,
          color: deck.color,
          createdAt: deck.createdAt,
        );
      }
      return deck;
    }).toList();

    // Обновляем карточку в списке для отображения
    final updatedCardWithDeck = CardWithDeck(
      card: updatedCard,
      deckId: _current!.deckId,
      deckName: _current!.deckName,
    );
    _studyCards[_currentIndex] = updatedCardWithDeck;

    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex += 1;
        _isFlipped = false;
        _completed += 1;
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

  Flashcard _calculateNextReview(Flashcard card, _Difficulty d) {
    int interval = card.interval;
    double ease = card.easeFactor;
    int reps = card.repetitions;

    switch (d) {
      case _Difficulty.again:
        interval = 1;
        reps = 0;
        ease = (ease - 0.2).clamp(1.3, 10.0);
        break;
      case _Difficulty.hard:
        interval = (interval * 1.2).round().clamp(1, 36500);
        ease = (ease - 0.15).clamp(1.3, 10.0);
        reps = reps + 1;
        break;
      case _Difficulty.good:
        if (reps == 0) {
          interval = 1;
        } else if (reps == 1) {
          interval = 6;
        } else {
          interval = (interval * ease).round();
        }
        reps = reps + 1;
        break;
      case _Difficulty.easy:
        interval = reps == 0 ? 4 : (interval * ease * 1.3).round();
        ease = ease + 0.15;
        reps = reps + 1;
        break;
    }
    
    final next = DateTime.now().add(Duration(days: interval));
    return Flashcard(
      id: card.id,
      front: card.front,
      back: card.back,
      nextReview: next,
      interval: interval,
      easeFactor: ease,
      repetitions: reps,
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

