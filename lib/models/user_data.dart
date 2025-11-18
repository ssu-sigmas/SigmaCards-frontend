import 'deck.dart';

enum AppTheme { light, dark }

class UserData {
  final bool isAuthenticated;
  final bool hasCompletedOnboarding;
  final List<Deck> decks;
  final int studyStreak;
  final AppTheme theme;

  UserData({
    this.isAuthenticated = false,
    required this.hasCompletedOnboarding,
    required this.decks,
    required this.studyStreak,
    required this.theme,
  });

  int get totalCards => decks.fold(0, (sum, deck) => sum + deck.cards.length);

  int get dueCardsCount {
    final today = DateTime.now();
    return decks.fold(0, (total, deck) {
      return total + deck.cards.where((card) => 
        card.nextReview.isBefore(today) || 
        card.nextReview.isAtSameMomentAs(today)).length;
    });
  }

  UserData copyWith({
    bool? isAuthenticated,
    bool? hasCompletedOnboarding,
    List<Deck>? decks,
    int? studyStreak,
    AppTheme? theme,
  }) {
    return UserData(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      decks: decks ?? this.decks,
      studyStreak: studyStreak ?? this.studyStreak,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() => {
        'isAuthenticated': isAuthenticated,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'decks': decks.map((deck) => deck.toJson()).toList(),
        'studyStreak': studyStreak,
        'theme': theme.name,
      };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        isAuthenticated: json['isAuthenticated'] ?? false,
        hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
        decks: (json['decks'] as List? ?? [])
            .map((deck) => Deck.fromJson(deck))
            .toList(),
        studyStreak: json['studyStreak'] ?? 0,
        theme: AppTheme.values.firstWhere(
          (e) => e.name == json['theme'],
          orElse: () => AppTheme.light,
        ),
      );
}
