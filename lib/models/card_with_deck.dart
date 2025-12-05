import 'flashcard.dart';

/// Карточка с информацией о колоде, из которой она взята
/// Используется в Quick Study Session для отображения названия колоды
class CardWithDeck {
  final Flashcard card;
  final String deckId;
  final String deckName;
  final String? userCardId; // UUID UserCard для отправки оценок через API

  CardWithDeck({
    required this.card,
    required this.deckId,
    required this.deckName,
    this.userCardId,
  });
}






