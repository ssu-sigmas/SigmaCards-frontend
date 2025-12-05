import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/due_card.dart';
import '../services/api_service.dart';
import '../theme/app_styles.dart';
import '../theme/app_colors.dart';

class StudySessionScreen extends StatefulWidget {
  final Deck deck;
  final void Function(Deck updatedDeck) onComplete;

  const StudySessionScreen({
    super.key,
    required this.deck,
    required this.onComplete,
  });

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  List<DueCard> _studyCards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _completed = 0;
  bool _isLoading = true;
  DateTime? _cardStartTime; // Для отслеживания времени ответа

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    // Если пользователь авторизован, загружаем due cards с сервера
    if (await ApiService.isAuthenticated()) {
      try {
        final result = await ApiService.getDueCards(
          deckId: widget.deck.id,
          limit: 100,
        );
        
        if (mounted) {
          if (result['success'] == true) {
            final cardsData = result['cards'] as List;
            final dueCards = cardsData
                .map((cardJson) => DueCard.fromJson(cardJson as Map<String, dynamic>))
                .toList();
            
            setState(() {
              _studyCards = dueCards;
              _isLoading = false;
            });
          } else {
            setState(() {
              _studyCards = [];
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _studyCards = [];
            _isLoading = false;
          });
        }
      }
    } else {
      // Если не авторизован, используем локальные карточки
      if (widget.deck.cards != null && widget.deck.cards!.isNotEmpty) {
        // Конвертируем Flashcard в DueCard для совместимости
        final dueCards = widget.deck.cards!.map((card) {
          return DueCard(
            userCardId: '', // Нет user_card_id для локальных карточек
            cardId: card.id,
            content: card.content,
            state: 0,
            stability: 0.0,
            difficulty: 0.0,
          );
        }).toList();
        
        setState(() {
          _studyCards = dueCards;
          _isLoading = false;
        });
      } else {
        setState(() {
          _studyCards = [];
          _isLoading = false;
        });
      }
    }
  }

  DueCard? get _current => _currentIndex < _studyCards.length ? _studyCards[_currentIndex] : null;

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
    
    final dueCard = _current!;
    final rating = _difficultyToRating(d);
    
    // Вычисляем время ответа
    final durationMs = _cardStartTime != null
        ? DateTime.now().difference(_cardStartTime!).inMilliseconds
        : 0;

    // Если есть userCardId, отправляем оценку на сервер
    if (dueCard.userCardId.isNotEmpty && await ApiService.isAuthenticated()) {
      try {
        final result = await ApiService.submitReview(
          userCardId: dueCard.userCardId,
          rating: rating,
          durationMs: durationMs,
        );

        if (result['success'] == true) {
          // Оценка успешно отправлена, FSRS обновлен на сервере
          // Просто переходим к следующей карточке
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

    // Обновляем локальное состояние
    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex += 1;
        _isFlipped = false;
        _completed += 1;
        _cardStartTime = null;
      });
    } else {
      setState(() {
        _completed += 1;
      });
      
      // Обновляем колоду (для совместимости с локальным режимом)
      final updatedDeck = widget.deck.copyWith(
        updatedAt: DateTime.now(),
      );
      widget.onComplete(updatedDeck);
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_studyCards.isEmpty || _current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: const Center(child: Text('No cards to study')),
      );
    }

    final progress = _studyCards.isEmpty ? 0.0 : (_completed + (_isFlipped ? 1 : 0)) / _studyCards.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(widget.deck.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress == 0 ? null : progress),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isFlipped
                        ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF2563EB)])
                        : null,
                    color: _isFlipped ? null : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isFlipped ? 'Answer' : 'Question',
                          style: TextStyle(
                            color: _isFlipped ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isFlipped ? _current!.back : _current!.front,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _isFlipped ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to ${_isFlipped ? 'hide' : 'reveal'}',
                          style: TextStyle(
                            color: _isFlipped ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isFlipped)
              Column(
                children: [
                  Text(
                    'How well did you know this?',
                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.again),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF9A9A)),
                          ),
                          child: const Text('Again'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.hard),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFCC80)),
                          ),
                          child: const Text('Hard'),
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
                          child: const Text('Good'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleDifficulty(_Difficulty.easy),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Easy'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                'Tap the card to reveal',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Difficulty { again, hard, good, easy }






