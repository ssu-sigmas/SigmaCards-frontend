import 'dart:convert';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/due_card.dart';
import '../services/api_service.dart';
import '../theme/app_styles.dart';
import '../theme/app_colors.dart';

class StudySessionScreen extends StatefulWidget {
  final Deck deck;
  final void Function(Deck updatedDeck, int cardsReviewed) onComplete;

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
  DateTime? _cardStartTime;
  final Map<_Difficulty, int> _ratingCounts = {
    _Difficulty.again: 0,
    _Difficulty.hard: 0,
    _Difficulty.good: 0,
    _Difficulty.easy: 0,
  };

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
      if (_isFlipped) {
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
          version: dueCard.version,
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

    _ratingCounts[d] = (_ratingCounts[d] ?? 0) + 1;

    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex += 1;
        _isFlipped = false;
        _completed += 1;
        _cardStartTime = null;
      });
    } else {
      setState(() => _completed += 1);
      final updatedDeck = widget.deck.copyWith(updatedAt: DateTime.now());
      widget.onComplete(updatedDeck, _studyCards.length);
      if (mounted) _showCompletionSheet();
    }
  }

  void _showCompletionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
            const SizedBox(height: 12),
            Text(
              'Сессия завершена!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Повторено карточек: ${_studyCards.length}',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RatingChip(label: 'Again', count: _ratingCounts[_Difficulty.again] ?? 0, color: const Color(0xFFEF9A9A)),
                _RatingChip(label: 'Hard', count: _ratingCounts[_Difficulty.hard] ?? 0, color: const Color(0xFFFFCC80)),
                _RatingChip(label: 'Good', count: _ratingCounts[_Difficulty.good] ?? 0, color: Colors.blue),
                _RatingChip(label: 'Easy', count: _ratingCounts[_Difficulty.easy] ?? 0, color: Colors.green),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Готово', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required bool isDark,
    required bool isBack,
    ImageProvider? imageProvider,
  }) {
    final bgColor = isBack ? null : (isDark ? AppColors.darkCard : AppColors.lightCard);
    final gradient = isBack
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
          )
        : null;
    final labelColor = isBack
        ? Colors.white60
        : (isDark ? Colors.grey[500]! : Colors.grey[600]!);
    final textColor = isBack ? Colors.white : (isDark ? Colors.white : Colors.black87);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bgColor,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBack ? 'Ответ' : 'Вопрос',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 16),
            if (isBack && imageProvider != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: imageProvider,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              isBack ? (_current?.back ?? '') : (_current?.front ?? ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isBack ? Icons.visibility_off_rounded : Icons.touch_app_rounded,
                  size: 16,
                  color: labelColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isBack ? 'Нажмите, чтобы скрыть' : 'Нажмите, чтобы открыть',
                  style: TextStyle(fontSize: 13, color: labelColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons(bool isDark, {Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Насколько хорошо вы знали ответ?',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ratingBtn(
              label: 'Снова',
              color: const Color(0xFFEF5350),
              onTap: () => _handleDifficulty(_Difficulty.again),
            ),
            const SizedBox(width: 8),
            _ratingBtn(
              label: 'Сложно',
              color: const Color(0xFFFFA726),
              onTap: () => _handleDifficulty(_Difficulty.hard),
            ),
            const SizedBox(width: 8),
            _ratingBtn(
              label: 'Хорошо',
              color: const Color(0xFF2563EB),
              onTap: () => _handleDifficulty(_Difficulty.good),
            ),
            const SizedBox(width: 8),
            _ratingBtn(
              label: 'Легко',
              color: const Color(0xFF16A34A),
              onTap: () => _handleDifficulty(_Difficulty.easy),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratingBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withValues(alpha: 0.25),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
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
    final imageProvider = _imageFromDataUrl(_current?.content['image'] as String?);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_studyCards.isEmpty || _current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Отлично! Все карточки повторены.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Следующий повтор — завтра.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Назад'),
                ),
              ],
            ),
          ),
        ),
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
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress == 0 ? null : progress,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_completed/${_studyCards.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 1 : 0),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, _) {
                    final angle = value * pi;
                    final isFrontVisible = angle < pi / 2;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isFrontVisible
                          ? _buildCardFace(
                              isDark: isDark,
                              isBack: false,
                              imageProvider: imageProvider,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildCardFace(
                                isDark: isDark,
                                isBack: true,
                                imageProvider: imageProvider,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _isFlipped
                  ? _buildRatingButtons(isDark, key: const ValueKey('rating'))
                  : Padding(
                      key: const ValueKey('hint'),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Нажмите на карточку, чтобы увидеть ответ',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Difficulty { again, hard, good, easy }

class _RatingChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _RatingChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

ImageProvider? _imageFromDataUrl(String? dataUrl) {
  if (dataUrl == null || dataUrl.isEmpty) return null;
  final parts = dataUrl.split(',');
  if (parts.length < 2) return null;
  try {
    return MemoryImage(base64Decode(parts.last));
  } catch (_) {
    return null;
  }
}






