String _textFromBlocks(dynamic blocks) {
  if (blocks is String) return blocks;
  if (blocks is List) {
    for (final b in blocks) {
      if (b is Map && b['type'] == 'text') return b['content'] as String? ?? '';
    }
  }
  return '';
}

String? _imageUrlFromBlocks(dynamic blocks) {
  if (blocks is List) {
    for (final b in blocks) {
      if (b is Map && b['type'] == 'image') return b['image_url'] as String?;
    }
  }
  return null;
}

// Модель для карточки на повтор (due card) из API
class DueCard {
  final String userCardId; // UUID UserCard
  final String cardId; // UUID Flashcard
  final Map<String, dynamic> content; // JSON с front/back
  final int state; // 0-3 (FSRS state)
  final double stability; // FSRS stability
  final double difficulty; // FSRS difficulty
  final int version; // Optimistic locking version

  DueCard({
    required this.userCardId,
    required this.cardId,
    required this.content,
    required this.state,
    required this.stability,
    required this.difficulty,
    this.version = 1,
  });

  String get front => _textFromBlocks(content['front']);
  String get back => _textFromBlocks(content['back']);
  String? get imageUrl => _imageUrlFromBlocks(content['back']) ?? content['image_url'] as String?;

  factory DueCard.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as Map<String, dynamic>;
    final front = rawContent['front'];
    final normalizedContent = (front is List)
        ? {
            'front': _textFromBlocks(front),
            'back': _textFromBlocks(rawContent['back']),
            if (_imageUrlFromBlocks(rawContent['back']) != null)
              'image_url': _imageUrlFromBlocks(rawContent['back']),
          }
        : rawContent;

    return DueCard(
      userCardId: json['user_card_id'] as String,
      cardId: json['card_id'] as String,
      content: normalizedContent,
      state: json['state'] as int,
      stability: (json['stability'] as num).toDouble(),
      difficulty: (json['difficulty'] as num).toDouble(),
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_card_id': userCardId,
        'card_id': cardId,
        'content': content,
        'state': state,
        'stability': stability,
        'difficulty': difficulty,
        'version': version,
      };
}






