import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
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
  late List<Flashcard> _studyCards;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final due = widget.deck.cards.where((c) => !c.nextReview.isAfter(today)).toList();
    _studyCards = due.isNotEmpty ? due : [...widget.deck.cards];
  }

  Flashcard? get _current => _currentIndex < _studyCards.length ? _studyCards[_currentIndex] : null;

  void _flip() => setState(() => _isFlipped = !_isFlipped);

  void _handleDifficulty(_Difficulty d) {
    if (_current == null) return;
    final updatedCard = _calculateNextReview(_current!, d);
    final updatedCards = widget.deck.cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
    final updatedDeck = Deck(
      id: widget.deck.id,
      name: widget.deck.name,
      description: widget.deck.description,
      cards: updatedCards,
      color: widget.deck.color,
      createdAt: widget.deck.createdAt,
    );

    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex += 1;
        _isFlipped = false;
        _completed += 1;
      });
    } else {
      setState(() {
        _completed += 1;
      });
      widget.onComplete(updatedDeck);
      Navigator.of(context).pop();
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

    if (_current == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: const Center(child: Text('No cards to study')),
      );
    }

    final progress = _studyCards.isEmpty ? 0.0 : _completed / _studyCards.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(widget.deck.name),
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

