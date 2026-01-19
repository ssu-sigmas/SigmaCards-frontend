import 'deck.dart';

enum AppTheme { light, dark }

class UserData {
  final bool isAuthenticated;
  final bool hasCompletedOnboarding;
  final List<Deck> decks;
  final int studyStreak;
  /// Повторённые карточки по дням, ключ `yyyy-MM-dd` (локальная дата).
  final Map<String, int> dailyReviewCounts;
  final AppTheme theme;
  final String? userId; // UUID текущего пользователя

  UserData({
    this.isAuthenticated = false,
    required this.hasCompletedOnboarding,
    required this.decks,
    required this.studyStreak,
    this.dailyReviewCounts = const {},
    required this.theme,
    this.userId,
  });

  int get totalCards => decks.fold(0, (sum, deck) => 
    sum + (deck.cards?.length ?? deck.flashcardsCount));

  int get dueCardsCount {
    // TODO: Реализовать через API /review/due после интеграции
    // Пока возвращаем 0, так как nextReview теперь в UserCard
    return 0;
  }

  UserData copyWith({
    bool? isAuthenticated,
    bool? hasCompletedOnboarding,
    List<Deck>? decks,
    int? studyStreak,
    Map<String, int>? dailyReviewCounts,
    AppTheme? theme,
    String? userId,
  }) {
    return UserData(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      decks: decks ?? this.decks,
      studyStreak: studyStreak ?? this.studyStreak,
      dailyReviewCounts: dailyReviewCounts ?? this.dailyReviewCounts,
      theme: theme ?? this.theme,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
        'isAuthenticated': isAuthenticated,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'decks': decks.map((deck) => deck.toJson()).toList(),
        'studyStreak': studyStreak,
        'dailyReviewCounts': dailyReviewCounts,
        'theme': theme.name,
        'userId': userId,
      };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        isAuthenticated: json['isAuthenticated'] ?? false,
        hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
        decks: (json['decks'] as List? ?? [])
            .map((deck) => Deck.fromJson(deck))
            .toList(),
        studyStreak: json['studyStreak'] ?? 0,
        dailyReviewCounts: _parseDailyCounts(json['dailyReviewCounts']),
        theme: AppTheme.values.firstWhere(
          (e) => e.name == json['theme'],
          orElse: () => AppTheme.light,
        ),
        userId: json['userId'] as String?,
      );

  static Map<String, int> _parseDailyCounts(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }
}
