import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../widgets/create_deck/deck_info_form.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                    onPressed: () {
                      // TODO: Implement save with validation
                      widget.onCancel();
                    },
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

