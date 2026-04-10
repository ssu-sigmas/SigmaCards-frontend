import 'package:flutter/material.dart';

/// Анимированный прямоугольный placeholder.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.07);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.13)
        : Colors.black.withValues(alpha: 0.13);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(base, highlight, _anim.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Placeholder, имитирующий карточку колоды.
class DeckCardSkeleton extends StatelessWidget {
  const DeckCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.25)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            width: 3,
          ),
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          right: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 54, height: 54, borderRadius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 16, borderRadius: 6),
                const SizedBox(height: 8),
                SkeletonBox(width: 160, height: 12, borderRadius: 6),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SkeletonBox(width: 80, height: 26, borderRadius: 20),
                    const SizedBox(width: 8),
                    SkeletonBox(width: 64, height: 26, borderRadius: 20),
                    const Spacer(),
                    SkeletonBox(width: 44, height: 44, borderRadius: 22),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Список скелетон-карточек с отступами — используется пока колоды грузятся.
class DeckListSkeleton extends StatelessWidget {
  final int count;

  const DeckListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DeckCardSkeleton(key: ValueKey(i)),
        ),
      ),
    );
  }
}
