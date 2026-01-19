import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/ru_plural.dart';
import '../../utils/study_activity.dart';

/// Карта активности по дням (стиль GitHub contributions).
class StreakHeatmapSection extends StatelessWidget {
  final Map<String, int> dailyReviewCounts;
  final int longestStreak;
  final bool isDark;

  const StreakHeatmapSection({
    super.key,
    required this.dailyReviewCounts,
    required this.longestStreak,
    required this.isDark,
  });

  static const int _weeks = 53;
  static const double _gap = 3;
  static const double _cell = 11;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final gridStartMonday = mondayThisWeek.subtract(Duration(days: (_weeks - 1) * 7));
    final year = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.defaultPadding,
        8,
        AppStyles.defaultPadding,
        4,
      ),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.28 : 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Активность',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _weekdayLabels(context),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(7, (row) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: row < 6 ? _gap : 0),
                          child: Row(
                            children: List.generate(_weeks, (col) {
                              final cellDate = gridStartMonday.add(Duration(days: col * 7 + row));
                              return Padding(
                                padding: EdgeInsets.only(right: col < _weeks - 1 ? _gap : 0),
                                child: _HeatCell(
                                  date: cellDate,
                                  today: today,
                                  count: dailyReviewCounts[studyDateKey(cellDate)] ?? 0,
                                  isDark: isDark,
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '$year',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  children: [
                    const TextSpan(text: 'Самая длинная серия: '),
                    TextSpan(
                      text: longestStreak <= 0
                          ? '—'
                          : '$longestStreak ${ruDaysWord(longestStreak)}',
                      style: TextStyle(
                        color: isDark ? AppColors.streakIconColor : const Color(0xFF15803D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekdayLabels(BuildContext context) {
    const labels = ['Пн', '', 'Ср', '', 'Пт', '', 'Вс'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (row) {
        return SizedBox(
          height: _cell,
          child: Padding(
            padding: EdgeInsets.only(bottom: row < 6 ? _gap : 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                labels[row],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      fontSize: 9,
                      height: 1,
                    ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final int count;
  final bool isDark;

  const _HeatCell({
    required this.date,
    required this.today,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (date.isAfter(today)) {
      return const SizedBox(
        width: StreakHeatmapSection._cell,
        height: StreakHeatmapSection._cell,
      );
    }

    final level = StudyActivity.intensityLevel(count);
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

    return Tooltip(
      message: '${studyDateKey(date)} · ${ruCardCountLabel(count)}',
      child: Container(
        width: StreakHeatmapSection._cell,
        height: StreakHeatmapSection._cell,
        decoration: BoxDecoration(
          color: _cellColor(level),
          borderRadius: BorderRadius.circular(3),
          border: isToday
              ? Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87,
                  width: 1.5,
                )
              : null,
        ),
      ),
    );
  }

  Color _cellColor(int level) {
    if (level == 0) {
      return isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.shade300;
    }
    const darkGreens = [
      Color(0xFF0D4429),
      Color(0xFF006D32),
      Color(0xFF26A641),
      Color(0xFF39D353),
    ];
    const lightGreens = [
      Color(0xFF9BE9A8),
      Color(0xFF40C463),
      Color(0xFF30D158),
      Color(0xFF216E39),
    ];
    final idx = (level - 1).clamp(0, 3);
    return isDark ? darkGreens[idx] : lightGreens[idx];
  }
}
