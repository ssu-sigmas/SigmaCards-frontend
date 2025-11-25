import 'flashcard.dart';
import 'enums.dart';

class Deck {
  final String id; // UUID как строка
  final String userId; // UUID пользователя
  final String title; // Было name
  final String? description;
  final DeckStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int flashcardsCount; // Количество карточек (из API)
  
  // Локальное поле для хранения карточек (не приходит из API)
  final List<Flashcard>? cards;

  Deck({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.status = DeckStatus.private,
    required this.createdAt,
    required this.updatedAt,
    this.flashcardsCount = 0,
    this.cards,
  });

  // Для обратной совместимости
  String get name => title;

  int get dueCardsCount {
    if (cards == null) return 0;
    final today = DateTime.now();
    return cards!.where((card) => 
      card.createdAt.isBefore(today) || 
      card.createdAt.isAtSameMomentAs(today)).length;
  }

  Deck copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DeckStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? flashcardsCount,
    List<Flashcard>? cards,
  }) {
    return Deck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flashcardsCount: flashcardsCount ?? this.flashcardsCount,
      cards: cards ?? this.cards,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'status': status.value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'flashcards_count': flashcardsCount,
        // Для обратной совместимости сохраняем старые поля
        'name': title,
        'color': 'bg-purple-500', // Дефолтный цвет для совместимости
        'createdAt': createdAt.toIso8601String(),
        // Сохраняем cards только если они есть
        if (cards != null) 'cards': cards!.map((card) => card.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) {
    // Поддержка старого формата для обратной совместимости
    final isOldFormat = json.containsKey('name') && json.containsKey('color');
    
    if (isOldFormat) {
      return Deck(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? '',
        title: json['name'] as String? ?? json['title'] as String,
        description: json['description'] as String?,
        status: json['status'] != null
            ? DeckStatus.fromString(json['status'] as String)
            : DeckStatus.private,
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
        flashcardsCount: json['flashcards_count'] as int? ?? 
            (json['cards'] as List?)?.length ?? 0,
        cards: json['cards'] != null
            ? (json['cards'] as List)
                .map((card) => Flashcard.fromJson(card as Map<String, dynamic>))
                .toList()
            : null,
      );
    }

    // Новый формат из API
    return Deck(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: DeckStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      flashcardsCount: json['flashcards_count'] as int? ?? 0,
      cards: null, // Карточки загружаются отдельно
    );
  }
}
