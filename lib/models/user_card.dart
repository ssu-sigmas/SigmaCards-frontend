class UserCard {
  final String id; // UUID user_card_id
  final String cardId; // UUID карточки
  final int state; // 0-3 (FSRS state)
  final double stability; // FSRS stability
  final double difficulty; // FSRS difficulty
  final DateTime nextDue; // Следующее повторение
  final DateTime? lastReview; // Последнее повторение

  UserCard({
    required this.id,
    required this.cardId,
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.nextDue,
    this.lastReview,
  });

  UserCard copyWith({
    String? id,
    String? cardId,
    int? state,
    double? stability,
    double? difficulty,
    DateTime? nextDue,
    DateTime? lastReview,
  }) {
    return UserCard(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      state: state ?? this.state,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      nextDue: nextDue ?? this.nextDue,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_card_id': id,
        'card_id': cardId,
        'state': state,
        'stability': stability,
        'difficulty': difficulty,
        'next_due': nextDue.toIso8601String(),
        'last_review': lastReview?.toIso8601String(),
      };

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['user_card_id'] as String? ?? json['id'] as String,
      cardId: json['card_id'] as String,
      state: json['state'] as int? ?? 0,
      stability: (json['stability'] as num?)?.toDouble() ?? 0.0,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
      nextDue: json['next_due'] != null
          ? DateTime.parse(json['next_due'] as String)
          : json['nextDue'] != null
              ? DateTime.parse(json['nextDue'] as String)
              : DateTime.now(),
      lastReview: json['last_review'] != null
          ? DateTime.parse(json['last_review'] as String)
          : json['lastReview'] != null
              ? DateTime.parse(json['lastReview'] as String)
              : null,
    );
  }
}

