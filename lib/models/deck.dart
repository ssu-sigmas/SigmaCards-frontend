import 'flashcard.dart';

class Deck {
  final String id;
  final String name;
  final String description;
  final List<Flashcard> cards;
  final String color;
  final DateTime createdAt;

  Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.cards,
    required this.color,
    required this.createdAt,
  });

  int get dueCardsCount {
    final today = DateTime.now();
    return cards.where((card) => 
      card.nextReview.isBefore(today) || 
      card.nextReview.isAtSameMomentAs(today)).length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cards': cards.map((card) => card.toJson()).toList(),
        'color': color,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        cards: (json['cards'] as List)
            .map((card) => Flashcard.fromJson(card))
            .toList(),
        color: json['color'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

