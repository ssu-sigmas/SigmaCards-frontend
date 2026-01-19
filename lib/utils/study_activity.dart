import '../models/user_data.dart';

/// Локальная дата (без времени) в ключе `yyyy-MM-dd`.
String studyDateKey(DateTime d) {
  final x = DateTime(d.year, d.month, d.day);
  return '${x.year.toString().padLeft(4, '0')}-'
      '${x.month.toString().padLeft(2, '0')}-'
      '${x.day.toString().padLeft(2, '0')}';
}

class StudyActivity {
  StudyActivity._();

  /// Учёт повторённых карточек за сегодня + пересчёт [UserData.studyStreak].
  static UserData recordReviews(UserData user, int count) {
    if (count <= 0) return user;
    final map = Map<String, int>.from(user.dailyReviewCounts);
    final key = studyDateKey(DateTime.now());
    map[key] = (map[key] ?? 0) + count;
    final pruned = _pruneOld(map);
    return user.copyWith(
      dailyReviewCounts: pruned,
      studyStreak: computeCurrentStreak(pruned),
    );
  }

  static Map<String, int> _pruneOld(Map<String, int> map) {
    final cutoff = DateTime.now().subtract(const Duration(days: 420));
    final k0 = studyDateKey(cutoff);
    return Map.fromEntries(map.entries.where((e) => e.key.compareTo(k0) >= 0));
  }

  /// Уровень яркости ячейки (0 — пусто, 1…4 — всё ярче).
  static int intensityLevel(int count) {
    if (count <= 0) return 0;
    if (count == 1) return 1;
    if (count <= 4) return 2;
    if (count <= 9) return 3;
    return 4;
  }

  /// Самая длинная серия дней подряд, в которые был хотя бы один повтор.
  static int computeLongestStreak(Map<String, int> map) {
    final dates = map.entries
        .where((e) => e.value > 0)
        .map((e) => DateTime.parse(e.key))
        .toList()
      ..sort();
    if (dates.isEmpty) return 0;
    var best = 1;
    var cur = 1;
    for (var i = 1; i < dates.length; i++) {
      final prev = dates[i - 1];
      final d = dates[i];
      final delta = d.difference(prev).inDays;
      if (delta == 1) {
        cur++;
        if (cur > best) best = cur;
      } else if (delta != 0) {
        cur = 1;
      }
    }
    return best;
  }

  /// Текущая серия: идём от сегодня (или вчера, если сегодня ещё пусто) назад по дням с активностью.
  static int computeCurrentStreak(Map<String, int> map) {
    var d = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if ((map[studyDateKey(d)] ?? 0) == 0) {
      d = d.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while ((map[studyDateKey(d)] ?? 0) > 0) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
