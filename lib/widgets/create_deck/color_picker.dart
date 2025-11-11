import 'package:flutter/material.dart';
import '../../theme/app_styles.dart';

class DeckColorOption {
  final String token; // e.g., 'bg-purple-500'
  final Color color;   // display color
  const DeckColorOption(this.token, this.color);
}

const List<DeckColorOption> kDeckColors = [
  DeckColorOption('bg-purple-500', Color(0xFF7C3AED)),
  DeckColorOption('bg-blue-500', Color(0xFF3B82F6)),
  DeckColorOption('bg-pink-500', Color(0xFFEC4899)),
  DeckColorOption('bg-green-500', Color(0xFF22C55E)),
  DeckColorOption('bg-orange-500', Color(0xFFF97316)),
  DeckColorOption('bg-red-500', Color(0xFFEF4444)),
  DeckColorOption('bg-indigo-500', Color(0xFF6366F1)),
  DeckColorOption('bg-teal-500', Color(0xFF14B8A6)),
];

class ColorPicker extends StatelessWidget {
  final String selectedToken;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const ColorPicker({
    super.key,
    required this.selectedToken,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deck Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: AppStyles.sectionSpacing),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kDeckColors.map((opt) {
            final bool isSelected = opt.token == selectedToken;
            return GestureDetector(
              onTap: () => onChanged(opt.token),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: opt.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: opt.color.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
