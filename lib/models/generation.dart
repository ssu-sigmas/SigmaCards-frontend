class Generation {
  final String id;
  final String textPreview;
  final int cardsCount;
  final String status; // 'completed' | 'failed' | 'pending'
  final String? deckId;
  final DateTime createdAt;

  Generation({
    required this.id,
    required this.textPreview,
    required this.cardsCount,
    required this.status,
    this.deckId,
    required this.createdAt,
  });

  factory Generation.fromJson(Map<String, dynamic> json) {
    final text = json['text_preview'] as String? ??
        json['input_text'] as String? ?? '';
    return Generation(
      id: json['id'] as String,
      textPreview: text.length > 120 ? '${text.substring(0, 120)}…' : text,
      cardsCount: json['cards_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'completed',
      deckId: json['deck_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
