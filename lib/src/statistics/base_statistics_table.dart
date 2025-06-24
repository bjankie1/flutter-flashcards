import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
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
        child: Text(
          label,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: bold ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}

enum StatisticType { totalCount, totalTime, avgTime }

class BaseStatistic extends StatelessWidget {
  final Iterable<model.CardAnswer> answers;

  final StatisticType type;

  const BaseStatistic({required this.answers, required this.type});

  Duration get totalTime {
    return answers.fold<Duration>(
      Duration.zero,
      (agg, next) => agg + next.timeSpent,
    );
  }

  Duration get averageTime {
    final days = answers
        .map((answer) => answer.reviewStart.dayStart)
        .toSet()
        .length;

    // Prevent division by zero when there's no data
    if (days == 0 || answers.isEmpty) {
      return Duration.zero;
    }

    return Duration(seconds: (totalTime.inSeconds / days).toInt());
  }

  String printDuration(BuildContext context, Duration duration) {
    final seconds = duration.inSeconds;
    final remainingSeconds = seconds % 60;
    final minutes = seconds ~/ 60;
    final remainingMinutes = minutes % 60;
    final hours = minutes ~/ 60;
    String result = '';
    if (hours > 0) {
      result = context.l10n.printHours(hours);
    }
    if (remainingMinutes > 0) {
      result +=
          (result.isNotEmpty ? ' ' : '') +
          context.l10n.printMinutes(remainingMinutes);
    }
    result +=
        (result.isNotEmpty ? ' ' : '') +
        context.l10n.printSeconds(remainingSeconds);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case StatisticType.totalCount:
        return Row(
          children: [
            ReportLabel(
              context.l10n.answersLabel,
              alignRight: true,
              bold: true,
            ),
            ReportLabel(answers.length.toString()),
          ],
        );
      case StatisticType.totalTime:
        return Row(
          children: [
            ReportLabel(
              context.l10n.totalTimeLabel,
              alignRight: true,
              bold: true,
            ),
            ReportLabel(printDuration(context, totalTime)),
          ],
        );
      case StatisticType.avgTime:
        return Row(
          children: [
            ReportLabel(
              context.l10n.averageTimeLabel,
              alignRight: true,
              bold: true,
            ),
            ReportLabel(printDuration(context, averageTime)),
          ],
        );
    }
  }
}
