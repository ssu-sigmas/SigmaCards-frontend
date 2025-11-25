enum DeckStatus {
  private,
  public,
  shared;

  String get value {
    switch (this) {
      case DeckStatus.private:
        return 'private';
      case DeckStatus.public:
        return 'public';
      case DeckStatus.shared:
        return 'shared';
    }
  }

  static DeckStatus fromString(String value) {
    switch (value) {
      case 'private':
        return DeckStatus.private;
      case 'public':
        return DeckStatus.public;
      case 'shared':
        return DeckStatus.shared;
      default:
        return DeckStatus.private;
    }
  }
}

enum CardType {
  keyTerms,
  facts,
  fillBlank,
  testQuestions,
  concepts;

  String get value {
    switch (this) {
      case CardType.keyTerms:
        return 'key_terms';
      case CardType.facts:
        return 'facts';
      case CardType.fillBlank:
        return 'fill_blank';
      case CardType.testQuestions:
        return 'test_questions';
      case CardType.concepts:
        return 'concepts';
    }
  }

  static CardType fromString(String value) {
    switch (value) {
      case 'key_terms':
        return CardType.keyTerms;
      case 'facts':
        return CardType.facts;
      case 'fill_blank':
        return CardType.fillBlank;
      case 'test_questions':
        return CardType.testQuestions;
      case 'concepts':
        return CardType.concepts;
      default:
        return CardType.keyTerms;
    }
  }
}

