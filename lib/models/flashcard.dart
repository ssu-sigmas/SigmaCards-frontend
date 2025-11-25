import 'enums.dart';

class Flashcard {
  final String id; // UUID как строка
  final String deckId; // UUID колоды
  final String? sourceId; // UUID исходной карточки (опционально)
  final CardType cardType;
  final Map<String, dynamic> content; // JSON с front/back/image/media
  final int position;
  final bool isSuspended;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.deckId,
    this.sourceId,
    required this.cardType,
    required this.content,
    this.position = 0,
    this.isSuspended = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Геттеры для удобного доступа к front и back
  String get front => content['front'] as String? ?? '';
  String get back => content['back'] as String? ?? '';

  // Сеттеры для обновления front и back
  Flashcard copyWithContent({
    String? front,
    String? back,
    Map<String, dynamic>? content,
  }) {
    final newContent = content ?? Map<String, dynamic>.from(this.content);
    if (front != null) newContent['front'] = front;
    if (back != null) newContent['back'] = back;

    return Flashcard(
      id: id,
      deckId: deckId,
      sourceId: sourceId,
      cardType: cardType,
      content: newContent,
      position: position,
      isSuspended: isSuspended,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? sourceId,
    CardType? cardType,
    Map<String, dynamic>? content,
    int? position,
    bool? isSuspended,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      sourceId: sourceId ?? this.sourceId,
      cardType: cardType ?? this.cardType,
      content: content ?? this.content,
      position: position ?? this.position,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deck_id': deckId,
        'source_id': sourceId,
        'card_type': cardType.value,
        'content': content,
        'position': position,
        'is_suspended': isSuspended,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    // Поддержка старого формата для обратной совместимости
    if (json.containsKey('front') && json.containsKey('back')) {
      return Flashcard(
        id: json['id'] as String,
        deckId: json['deck_id'] as String? ?? json['deckId'] as String? ?? '',
        sourceId: json['source_id'] as String? ?? json['sourceId'] as String?,
        cardType: json['card_type'] != null
            ? CardType.fromString(json['card_type'] as String)
            : CardType.keyTerms,
        content: {
          'front': json['front'] as String,
          'back': json['back'] as String,
        },
        position: json['position'] as int? ?? 0,
        isSuspended: json['is_suspended'] as bool? ?? json['isSuspended'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : DateTime.now(),
      );
    }

    // Новый формат
    return Flashcard(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      sourceId: json['source_id'] as String?,
      cardType: CardType.fromString(json['card_type'] as String),
      content: json['content'] as Map<String, dynamic>,
      position: json['position'] as int? ?? 0,
      isSuspended: json['is_suspended'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
