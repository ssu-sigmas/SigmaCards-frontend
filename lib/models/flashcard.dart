class Flashcard {
  final String id;
  final String front;
  final String back;
  final DateTime nextReview;
  final int interval;
  final double easeFactor;
  final int repetitions;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.nextReview,
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'nextReview': nextReview.toIso8601String(),
        'interval': interval,
        'easeFactor': easeFactor,
        'repetitions': repetitions,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'],
        front: json['front'],
        back: json['back'],
        nextReview: DateTime.parse(json['nextReview']),
        interval: json['interval'],
        easeFactor: json['easeFactor'].toDouble(),
        repetitions: json['repetitions'],
      );
}

