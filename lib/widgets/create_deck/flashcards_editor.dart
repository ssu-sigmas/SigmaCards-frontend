import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class FlashcardDraft {
  String front;
  String back;
  FlashcardDraft({this.front = '', this.back = ''});
  bool get isValid => front.trim().isNotEmpty && back.trim().isNotEmpty;
}

class FlashcardsEditor extends StatelessWidget {
  final List<FlashcardDraft> cards;
  final bool isDark;
  final VoidCallback onAddCard;
  final void Function(int index) onRemoveCard;
  final void Function(int index, String field, String value) onChange;

  const FlashcardsEditor({
    super.key,
    required this.cards,
    required this.isDark,
    required this.onAddCard,
    required this.onRemoveCard,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Flashcards',
              style: AppStyles.sectionTitle(isDark),
            ),
            TextButton.icon(
              onPressed: onAddCard,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Card'),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.sectionSpacing),
        Column(
          children: [
            for (int i = 0; i < cards.length; i++)
              _FlashcardItem(
                index: i,
                data: cards[i],
                isDark: isDark,
                onRemove: cards.length > 1 ? () => onRemoveCard(i) : null,
                onChange: onChange,
              ),
          ],
        ),
      ],
    );
  }
}

class _FlashcardItem extends StatelessWidget {
  final int index;
  final FlashcardDraft data;
  final bool isDark;
  final VoidCallback? onRemove;
  final void Function(int index, String field, String value) onChange;

  const _FlashcardItem({
    required this.index,
    required this.data,
    required this.isDark,
    required this.onRemove,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card ${index + 1}',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildField(
              context,
              label: 'Front',
              initialValue: data.front,
              onChanged: (v) => onChange(index, 'front', v),
            ),
            const SizedBox(height: 12),
            _buildField(
              context,
              label: 'Back',
              initialValue: data.back,
              onChanged: (v) => onChange(index, 'back', v),
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    int minLines = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initialValue),
          onChanged: onChanged,
          minLines: minLines,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: label == 'Front' ? 'Question or term' : 'Answer or definition',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.purple,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
