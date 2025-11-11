import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../widgets/create_deck/deck_info_form.dart';
import '../widgets/create_deck/color_picker.dart';
import '../widgets/create_deck/flashcards_editor.dart';

class CreateDeckScreen extends StatefulWidget {
  final Function(Deck) onSave;
  final VoidCallback onCancel;

  const CreateDeckScreen({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColorToken = 'bg-purple-500';
  final List<FlashcardDraft> _cards = [FlashcardDraft()];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleAddCard() {
    setState(() {
      _cards.add(FlashcardDraft());
    });
  }

  void _handleRemoveCard(int index) {
    setState(() {
      if (_cards.length > 1) _cards.removeAt(index);
    });
  }

  void _handleCardChange(int index, String field, String value) {
    setState(() {
      if (field == 'front') {
        _cards[index].front = value;
      } else {
        _cards[index].back = value;
      }
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter a deck name');
      return;
    }
    final validCards = _cards.where((c) => c.isValid).toList();
    if (validCards.isEmpty) {
      _showSnack('Please add at least one complete card');
      return;
    }

    final deck = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      color: _selectedColorToken,
      createdAt: DateTime.now(),
      cards: validCards.map((c) => Flashcard(
        id: UniqueKey().toString(),
        front: c.front.trim(),
        back: c.back.trim(),
        nextReview: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
        repetitions: 0,
      )).toList(),
    );

    widget.onSave(deck);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark 
                        ? Colors.grey[800]! 
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onCancel,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  Expanded(
                    child: Text(
                      'Create Deck',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeckInfoForm(
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    ColorPicker(
                      selectedToken: _selectedColorToken,
                      onChanged: (token) {
                        setState(() {
                          _selectedColorToken = token;
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    FlashcardsEditor(
                      cards: _cards,
                      isDark: isDark,
                      onAddCard: _handleAddCard,
                      onRemoveCard: _handleRemoveCard,
                      onChange: _handleCardChange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

