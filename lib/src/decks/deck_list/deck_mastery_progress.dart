import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/card_mastery.dart';
import '../../model/cards.dart' as model;
import '../../common/build_context_extensions.dart';
import 'deck_mastery_controller.dart';

class DeckMasteryProgress extends ConsumerWidget {
  final model.Deck deck;
  final bool isWide;

  const DeckMasteryProgress({
    super.key,
    required this.deck,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryAsync = ref.watch(deckMasteryControllerProvider(deck.id!));

    return masteryAsync.when(
      loading: () => isWide
          ? const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 6),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: LinearProgressIndicator(minHeight: 8),
            ),
      error: (error, stack) => isWide
          ? const Icon(Icons.error, color: Colors.red)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: 1.0,
                backgroundColor: Colors.red,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            ),
      data: (data) {
        final total = data.values.fold(0, (a, b) => a + b);
        final mastered =
            (data[CardMastery.young] ?? 0) + (data[CardMastery.mature] ?? 0);
        final progress = total == 0 ? 0.0 : mastered / total;

        void showReport() {
          showDialog(
            context: context,
            builder: (context) => DeckMasteryReportDialog(
              deckName: deck.name,
              breakdown: data,
              progress: progress,
            ),
          );
        }

        if (isWide) {
          // Circular progress for wide screens
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _HoverableCircularProgress(
              progress: progress,
              onTap: showReport,
              label: '${(progress * 100).round()}%',
            ),
          );
        } else {
          // Linear progress for narrow screens
          return GestureDetector(
            onTap: showReport,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 8, // Thicker bar
              ),
            ),
          );
        }
      },
    );
  }
}

class _HoverableCircularProgress extends StatefulWidget {
  final double progress;
  final VoidCallback onTap;
  final String label;

  const _HoverableCircularProgress({
    required this.progress,
    required this.onTap,
    required this.label,
  });

  @override
  State<_HoverableCircularProgress> createState() =>
      _HoverableCircularProgressState();
}

class _HoverableCircularProgressState
    extends State<_HoverableCircularProgress> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.primary;
    final hsl = HSLColor.fromColor(baseColor);
    final hoverColor = hsl
        .withSaturation((hsl.saturation * 1.3).clamp(0.0, 1.0))
        .toColor();
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: widget.progress,
                strokeWidth: 6,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _hovering ? hoverColor : baseColor,
                ),
              ),
              Text(widget.label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class DeckMasteryReportDialog extends StatelessWidget {
  final String deckName;
  final Map<CardMastery, int> breakdown;
  final double progress;

  const DeckMasteryReportDialog({
    super.key,
    required this.deckName,
    required this.breakdown,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0, (a, b) => a + b);
    final percent = (progress * 100).round();
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.deckProgress(deckName),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$percent%',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _MasteryBar(
                label: context.l10n.masteryNew,
                value: breakdown[CardMastery.new_] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
              _MasteryBar(
                label: context.l10n.masteryLearning,
                value: breakdown[CardMastery.learning] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
              _MasteryBar(
                label: context.l10n.masteryYoung,
                value: breakdown[CardMastery.young] ?? 0,
                total: total,
              ),
              const SizedBox(height: 8),
              _MasteryBar(
                label: context.l10n.masteryMature,
                value: breakdown[CardMastery.mature] ?? 0,
                total: total,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _MasteryBar({
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : value / total;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
