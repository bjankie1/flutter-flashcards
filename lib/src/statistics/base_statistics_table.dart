import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;

class ReportLabel extends StatelessWidget {
  final String label;
  final bool alignRight;
  final bool bold;

  const ReportLabel(
    this.label, {
    this.alignRight = false,
    this.bold = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: bold ? FontWeight.bold : null)),
        ),
      ),
    );
  }
}

class BaseStatisticsTable extends StatelessWidget {
  final Iterable<model.CardAnswer> result;
  const BaseStatisticsTable(this.result);

  String printDuration(BuildContext context, Duration duration) {
    final seconds = duration.inSeconds;
    final remainingSeconds = seconds % 60;
    final minutes = seconds ~/ 60;
    final remainingMinutes = minutes % 60;
    final hours = minutes ~/ 60;
    String result = '';
    if (hours > 0) {
      result += context.l10n.printHours(hours);
    }
    if (remainingMinutes > 0) {
      result += context.l10n.printMinutes(remainingMinutes);
    }
    result += result += context.l10n.printSeconds(remainingSeconds);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: <Widget>[
        Row(
          children: [
            ReportLabel(
              'Answers:',
              alignRight: true,
              bold: true,
            ),
            ReportLabel(result.length.toString()),
          ],
        ),
        Row(
          children: [
            ReportLabel(
              'Total time:',
              alignRight: true,
              bold: true,
            ),
            ReportLabel(printDuration(
                context,
                result.fold<Duration>(
                    Duration.zero, (agg, next) => agg + next.timeSpent))),
          ],
        ),
        Row(
          children: [
            ReportLabel(
              'Average (s):',
              alignRight: true,
              bold: true,
            ),
            ReportLabel(printDuration(
                context,
                result.fold<Duration>(
                    Duration.zero, (agg, next) => agg + next.timeSpent))),
          ],
        ),
      ],
    );
  }
}
