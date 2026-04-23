import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../utils/ru_plural.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onEdit;
  final VoidCallback onStudy;
  final VoidCallback onDelete;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onEdit,
    required this.onStudy,
    required this.onDelete,
  });

  static const List<Color> _accentPalette = [
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
    Color(0xFF4F46E5),
  ];

  Color _accent() => _accentPalette[deck.id.hashCode.abs() % _accentPalette.length];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final accent = _accent();
    final n = deck.cards?.length ?? deck.flashcardsCount;
    final canStudy = (deck.cards?.isNotEmpty ?? false) || deck.flashcardsCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canStudy ? onStudy : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent,
                        Color.lerp(accent, Colors.black, isDark ? 0.25 : 0.15)!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              deck.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _DeckSecondaryActions(
                            scheme: scheme,
                            isDark: isDark,
                            onEdit: onEdit,
                            onDelete: onDelete,
                          ),
                        ],
                      ),
                      if ((deck.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          deck.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.25,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _MetaChip(
                                  icon: Icons.style_rounded,
                                  label: ruCardCountLabel(n),
                                  isDark: isDark,
                                  subtle: true,
                                ),
                                if (deck.dueCardsCount > 0)
                                  _MetaChip(
                                    icon: Icons.schedule_rounded,
                                    label: '${deck.dueCardsCount} к повт.',
                                    isDark: isDark,
                                    accent: accent,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: canStudy ? onStudy : null,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(44, 44),
                              maximumSize: const Size(44, 44),
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: scheme.surfaceContainerHighest,
                              disabledForegroundColor: scheme.onSurfaceVariant,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Компактная группа «ред. / уд.» в одной капсуле справа от заголовка.
class _DeckSecondaryActions extends StatelessWidget {
  final ColorScheme scheme;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeckSecondaryActions({
    required this.scheme,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final border = scheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.65);
    final bg = scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.4 : 0.72);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniIconBtn(
              context: context,
              icon: Icons.edit_outlined,
              tooltip: 'Изменить',
              color: scheme.onSurfaceVariant,
              onPressed: onEdit,
            ),
            SizedBox(
              height: 22,
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            _miniIconBtn(
              context: context,
              icon: Icons.delete_outline_rounded,
              tooltip: 'Удалить',
              color: scheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniIconBtn({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool subtle;
  final Color? accent;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.subtle = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = accent;
    final bg = subtle
        ? scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.45 : 0.65)
        : (c?.withValues(alpha: isDark ? 0.22 : 0.12) ??
            scheme.primaryContainer.withValues(alpha: 0.35));
    final fg = subtle ? scheme.onSurfaceVariant : (c ?? scheme.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subtle ? fg : (isDark ? Colors.white.withValues(alpha: 0.92) : c),
            ),
          ),
        ],
      ),
    );
  }
}
