import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onStudy;
  final VoidCallback onDelete;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onStudy,
    required this.onDelete,
  });

  Color _getDeckColor() {
    // Используем фиолетовый по умолчанию, так как color больше нет в модели
    // Можно использовать статус или другой способ определения цвета
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deckColor = _getDeckColor();
    
    return Card(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
            const SizedBox(width: AppStyles.sectionSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 4),
                  Text(
                    deck.description ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${deck.cards?.length ?? deck.flashcardsCount} cards',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (deck.dueCardsCount > 0) ...[
                        const SizedBox(width: 16),
                        Text(
                          '${deck.dueCardsCount} due',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.purple[300] : Colors.purple[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  onPressed: (deck.cards?.isEmpty ?? deck.flashcardsCount == 0) ? null : onStudy,
                  icon: const Icon(Icons.play_arrow),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
