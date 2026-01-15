import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class FlashcardDraft {
  String? id;
  String front;
  String back;
  String? imageDataUrl;
  DateTime? createdAt;
  int position;

  FlashcardDraft({
    this.id,
    this.front = '',
    this.back = '',
    this.imageDataUrl,
    this.createdAt,
    this.position = 0,
  });

  bool get isValid => front.trim().isNotEmpty && back.trim().isNotEmpty;
}

class FlashcardsEditor extends StatelessWidget {
  final List<FlashcardDraft> cards;
  final bool isDark;
  final VoidCallback onAddCard;
  final void Function(int index) onRemoveCard;
  final void Function(int index, String field, String value) onChange;
  final void Function(int index, String? imageDataUrl) onImageChange;

  const FlashcardsEditor({
    super.key,
    required this.cards,
    required this.isDark,
    required this.onAddCard,
    required this.onRemoveCard,
    required this.onChange,
    required this.onImageChange,
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
                onImageChange: onImageChange,
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
  final void Function(int index, String? imageDataUrl) onImageChange;

  const _FlashcardItem({
    required this.index,
    required this.data,
    required this.isDark,
    required this.onRemove,
    required this.onChange,
    required this.onImageChange,
  });

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    const maxSize = 2 * 1024 * 1024;
    if (bytes.length > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Изображение слишком большое (максимум 2MB)')),
      );
      return;
    }

    final ext = (file.extension ?? 'png').toLowerCase();
    final mimeExt = ext == 'jpg' ? 'jpeg' : ext;
    final encoded = base64Encode(bytes);
    final dataUrl = 'data:image/$mimeExt;base64,$encoded';
    onImageChange(index, dataUrl);
  }

  Uint8List? _decodeImageBytes(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) return null;
    final parts = dataUrl.split(',');
    if (parts.length < 2) return null;
    try {
      return base64Decode(parts.last);
    } catch (_) {
      return null;
    }
  }

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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(Icons.image_outlined),
                    label: Text(data.imageDataUrl == null ? 'Добавить картинку' : 'Изменить картинку'),
                  ),
                  if (data.imageDataUrl != null)
                    TextButton.icon(
                      onPressed: () => onImageChange(index, null),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Удалить', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
            if (data.imageDataUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  width: double.infinity,
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  child: _decodeImageBytes(data.imageDataUrl) != null
                      ? Image.memory(
                          _decodeImageBytes(data.imageDataUrl)!,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(
                          height: 80,
                          child: Center(child: Text('Не удалось отобразить изображение')),
                        ),
                ),
              ),
            ],
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
