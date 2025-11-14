import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../widgets/create_deck/flashcards_editor.dart';

class ImportTextScreen extends StatefulWidget {
  const ImportTextScreen({super.key});

  @override
  State<ImportTextScreen> createState() => _ImportTextScreenState();
}

class _ImportTextScreenState extends State<ImportTextScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDocx() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['docx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        setState(() {
          _errorMessage = 'Не удалось прочитать файл.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final extractedText = await _extractDocxText(bytes);

      if (!mounted) return;

      if (extractedText.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Файл не содержит текста.';
        });
      } else {
        _textController.text = extractedText.trim();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ошибка при импорте DOCX: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _extractDocxText(Uint8List bytes) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final documentEntry = archive.firstWhere(
        (file) => file.name == 'word/document.xml',
        orElse: () => throw Exception('Файл document.xml не найден в архиве.'),
      );

      final content = utf8.decode(documentEntry.content);
      final xml = XmlDocument.parse(content);

      final buffer = StringBuffer();
      for (final paragraph in xml.findAllElements('w:p')) {
        final runs = paragraph.findAllElements('w:t');
        final paragraphText = runs.map((t) => t.innerText).join();
        if (paragraphText.trim().isNotEmpty) {
          buffer.writeln(paragraphText.trim());
        }
      }

      return buffer.toString();
    } catch (e) {
      throw Exception('Не удалось распаковать DOCX: $e');
    }
  }

  void _handleContinue() {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) {
      setState(() {
        _errorMessage = 'Сначала вставьте текст или импортируйте DOCX.';
      });
      return;
    }

    final drafts = _generateDrafts(rawText);
    if (drafts.isEmpty) {
      setState(() {
        _errorMessage = 'Не удалось преобразовать текст в карточки. Попробуйте отредактировать текст.';
      });
      return;
    }

    Navigator.of(context).pop(drafts);
  }

  List<FlashcardDraft> _generateDrafts(String text) {
    final segments = text.split(RegExp(r'\n{2,}'));
    final drafts = <FlashcardDraft>[];

    for (final segment in segments) {
      final trimmed = segment.trim();
      if (trimmed.isEmpty) continue;

      final lines = trimmed
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.isEmpty) continue;

      String front = lines.first;
      String back = lines.length > 1 ? lines.skip(1).join('\n') : '';

      if (back.isEmpty) {
        const separators = [':', ' — ', ' – ', ' - '];
        for (final separator in separators) {
          final index = front.indexOf(separator);
          if (index > 0 && index < front.length - separator.length) {
            final left = front.substring(0, index).trim();
            final right = front.substring(index + separator.length).trim();
            if (left.isNotEmpty && right.isNotEmpty) {
              front = left;
              back = right;
              break;
            }
          }
        }
      }

      drafts.add(FlashcardDraft(front: front, back: back));
    }

    return drafts;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: const Text('Импорт текста'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вставьте текст вручную или импортируйте файл DOCX. '
                'Текст будет автоматически разбит на карточки по абзацам.',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: AppStyles.sectionSpacing),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Вставьте текст сюда...',
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.purple,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(height: AppStyles.sectionSpacing),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickDocx,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(_isLoading ? 'Загрузка...' : 'Импорт DOCX'),
                      style: AppStyles.purpleButtonStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _textController.text.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _textController.clear();
                              _errorMessage = null;
                            });
                          },
                    icon: const Icon(Icons.clear),
                    tooltip: 'Очистить',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  child: const Text('Продолжить к созданию карточек'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


