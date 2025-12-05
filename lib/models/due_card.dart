// Модель для карточки на повтор (due card) из API
class DueCard {
  final String userCardId; // UUID UserCard
  final String cardId; // UUID Flashcard
  final Map<String, dynamic> content; // JSON с front/back
  final int state; // 0-3 (FSRS state)
  final double stability; // FSRS stability
  final double difficulty; // FSRS difficulty

  DueCard({
    required this.userCardId,
    required this.cardId,
    required this.content,
    required this.state,
    required this.stability,
    required this.difficulty,
  });

  // Геттеры для удобного доступа к front и back
  String get front => content['front'] as String? ?? '';
  String get back => content['back'] as String? ?? '';

  factory DueCard.fromJson(Map<String, dynamic> json) {
    return DueCard(
      userCardId: json['user_card_id'] as String,
      cardId: json['card_id'] as String,
      content: json['content'] as Map<String, dynamic>,
      state: json['state'] as int,
      stability: (json['stability'] as num).toDouble(),
      difficulty: (json['difficulty'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_card_id': userCardId,
        'card_id': cardId,
        'content': content,
        'state': state,
        'stability': stability,
        'difficulty': difficulty,
      };
}

