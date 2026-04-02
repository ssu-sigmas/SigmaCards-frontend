import 'package:flutter/material.dart';
import '../models/generation.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class GenerationHistoryScreen extends StatefulWidget {
  const GenerationHistoryScreen({super.key});

  @override
  State<GenerationHistoryScreen> createState() =>
      _GenerationHistoryScreenState();
}

class _GenerationHistoryScreenState extends State<GenerationHistoryScreen> {
  List<Generation> _generations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ApiService.getGenerations();
    if (!mounted) return;
    if (result['success'] == true) {
      final list = result['generations'] as List;
      setState(() {
        _generations = list
            .map((e) => Generation.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'] as String? ?? 'Ошибка загрузки';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('История генераций'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(context, isDark, scheme),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, ColorScheme scheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }

    if (_generations.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 56,
                  color: scheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'Нет генераций',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Создайте карточки из текста через AI,\nи они появятся здесь.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _generations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _GenerationTile(generation: _generations[index], isDark: isDark),
    );
  }
}

class _GenerationTile extends StatelessWidget {
  final Generation generation;
  final bool isDark;

  const _GenerationTile({required this.generation, required this.isDark});

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (generation.status) {
      'completed' => const Color(0xFF16A34A),
      'failed' => scheme.error,
      _ => scheme.onSurfaceVariant,
    };
  }

  String _statusLabel() => switch (generation.status) {
        'completed' => 'Готово',
        'failed' => 'Ошибка',
        'pending' => 'В процессе',
        _ => generation.status,
      };

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Сегодня, ${_time(dt)}';
    if (diff.inDays == 1) return 'Вчера, ${_time(dt)}';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(context),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(generation.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            if (generation.textPreview.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                generation.textPreview,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.style_rounded, size: 14, color: scheme.primary),
                const SizedBox(width: 5),
                Text(
                  '${generation.cardsCount} карточек',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
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
