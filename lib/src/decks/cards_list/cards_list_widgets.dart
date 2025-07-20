import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../model/cards.dart' as model;
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/dates.dart';

class CardStatsDialog extends StatelessWidget {
  final model.Card card;
  final List<model.CardStats> stats;

  const CardStatsDialog({super.key, required this.card, required this.stats});

  String _formatTimeAgo(BuildContext context, DateTime? date) {
    if (date == null) return context.l10n.learningStatisticsNotScheduled;
    final days = currentClockDateTime.difference(date).inDays;
    if (days == 0) return context.l10n.learningStatisticsToday;
    if (days == 1) return context.l10n.learningStatisticsYesterday;
    return context.l10n.learningStatisticsDay(days);
  }

  String _formatTimeToNext(BuildContext context, DateTime? date) {
    if (date == null) return context.l10n.learningStatisticsNotScheduled;
    final difference = date.difference(currentClockDateTime);
    if (!difference.isNegative && difference.inSeconds == 0)
      return context.l10n.learningStatisticsDueAlready;
    if (difference.isNegative) return context.l10n.learningStatisticsDueAlready;
    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    String dayStr = days > 0 ? context.l10n.learningStatisticsDay(days) : '';
    String hourStr = hours > 0
        ? context.l10n.learningStatisticsHour(hours)
        : '';
    if (dayStr.isNotEmpty && hourStr.isNotEmpty) {
      return '$dayStr $hourStr';
    } else if (dayStr.isNotEmpty) {
      return dayStr;
    } else if (hourStr.isNotEmpty) {
      return hourStr;
    } else {
      return context.l10n.learningStatisticsDueAlready;
    }
  }

  String _difficultyWord(BuildContext context, double difficulty) {
    if (difficulty <= 3.33) {
      return context.l10n.learningStatisticsDifficultyEasy;
    } else if (difficulty <= 6.66) {
      return context.l10n.learningStatisticsDifficultyMedium;
    } else {
      return context.l10n.learningStatisticsDifficultyHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool doubleSided = card.options?.learnBothSides ?? false;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      title: Text(context.l10n.learningStatisticsDialogTitle),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text(context.l10n.learningStatisticsMetric)),
            if (doubleSided)
              DataColumn(label: Text(context.l10n.learningStatisticsQuestion)),
            if (doubleSided)
              DataColumn(label: Text(context.l10n.learningStatisticsAnswer)),
            if (!doubleSided)
              DataColumn(label: Text(context.l10n.learningStatisticsValue)),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Text(context.l10n.learningStatisticsNumberOfReviews)),
                if (doubleSided) DataCell(Text('${stats[0].numberOfReviews}')),
                if (doubleSided) DataCell(Text('${stats[1].numberOfReviews}')),
                if (!doubleSided) DataCell(Text('${stats[0].numberOfReviews}')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text(context.l10n.learningStatisticsDifficulty)),
                if (doubleSided)
                  DataCell(Text(_difficultyWord(context, stats[0].difficulty))),
                if (doubleSided)
                  DataCell(Text(_difficultyWord(context, stats[1].difficulty))),
                if (!doubleSided)
                  DataCell(Text(_difficultyWord(context, stats[0].difficulty))),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text(context.l10n.learningStatisticsLastReview)),
                if (doubleSided)
                  DataCell(Text(_formatTimeAgo(context, stats[0].lastReview))),
                if (doubleSided)
                  DataCell(Text(_formatTimeAgo(context, stats[1].lastReview))),
                if (!doubleSided)
                  DataCell(Text(_formatTimeAgo(context, stats[0].lastReview))),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text(context.l10n.learningStatisticsNextReview)),
                if (doubleSided)
                  DataCell(
                    Text(_formatTimeToNext(context, stats[0].nextReviewDate)),
                  ),
                if (doubleSided)
                  DataCell(
                    Text(_formatTimeToNext(context, stats[1].nextReviewDate)),
                  ),
                if (!doubleSided)
                  DataCell(
                    Text(_formatTimeToNext(context, stats[0].nextReviewDate)),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.learningStatisticsClose),
        ),
      ],
    );
  }
}

class CardTile extends StatelessWidget {
  final model.Deck deck;
  final model.Card card;
  final List<model.CardStats> cardStats;
  final Function onDelete;

  CardTile({
    super.key,
    required this.deck,
    required this.card,
    required this.cardStats,
    required this.onDelete,
  });

  Widget _buildDifficultyIndicator(BuildContext context, double difficulty) {
    Color color;
    String label;

    if (difficulty <= 3.33) {
      color = Colors.green;
      label = context.l10n.learningStatisticsDifficultyEasy;
    } else if (difficulty <= 6.66) {
      color = Colors.orange;
      label = context.l10n.learningStatisticsDifficultyMedium;
    } else {
      color = Colors.red;
      label = context.l10n.learningStatisticsDifficultyHard;
    }

    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => CardStatsDialog(card: card, stats: cardStats),
          );
        },
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (card.options?.learnBothSides ?? false)
            Tooltip(
              message: context.l10n.cardOptionDoubleSidedTooltip,
              child: Icon(Icons.swap_vert_circle, color: Colors.green),
            ),
          if (card.explanation != null && card.explanation!.isNotEmpty)
            Tooltip(
              message: context.l10n.hintIconTooltip,
              child: Icon(Icons.info, color: Colors.blue),
            ),
        ],
      ),
      onTap: () async {
        await context.push('/decks/${deck.id}/cards/${card.id}');
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TrimmedTextWithLabel(
                  label: context.l10n.cardQuestionDisplay,
                  text: card.question,
                  maxWidth: 500,
                ),
              ),
              if (cardStats.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildDifficultyIndicator(
                    context,
                    cardStats[0].difficulty,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _TrimmedTextWithLabel(
                  label: context.l10n.cardAnswerDisplay,
                  text: card.answer,
                  maxWidth: 500,
                ),
              ),
              if (cardStats.length > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildDifficultyIndicator(
                    context,
                    cardStats[1].difficulty,
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Tooltip(
        message: context.l10n.deleteCardTooltip,
        child: IconButton(
          icon: const Icon(Icons.delete_outline, size: 32),
          onPressed: () {
            onDelete();
          },
        ),
      ),
    );
  }
}

class _TrimmedTextWithLabel extends StatelessWidget {
  final String label;
  final String text;
  final double maxWidth;

  const _TrimmedTextWithLabel({
    required this.label,
    required this.text,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
