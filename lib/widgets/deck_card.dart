import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
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

  Color _getDeckColor() {
    return Colors.purple.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deckColor = _getDeckColor();
    final n = deck.cards?.length ?? deck.flashcardsCount;

    return Card(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: deckColor,
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              ),
              child: const Icon(
                Icons.book_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    deck.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((deck.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      deck.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        ruCardCountLabel(n),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (deck.dueCardsCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.purple.shade900 : Colors.purple.shade50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${deck.dueCardsCount} к повт.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.purple[200] : Colors.purple[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 22),
                  style: IconButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                  tooltip: 'Изменить',
                ),
                IconButton(
                  onPressed: (deck.cards?.isEmpty ?? deck.flashcardsCount == 0) ? null : onStudy,
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade600,
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                  ),
                  tooltip: 'Учить',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, size: 22, color: Colors.red.shade400),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                  tooltip: 'Удалить',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
