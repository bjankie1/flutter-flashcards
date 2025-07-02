import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/build_context_extensions.dart';
import '../../model/cards.dart' as model;
import 'deck_info_controller.dart';

class DeckInfoWidget extends ConsumerWidget {
  final model.Deck deck;

  const DeckInfoWidget({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deck.id!));

    return cardCountAsync.when(
      data: (cardCount) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: context.l10n.cards,
            child: Icon(
              Icons.style,
              size: 16,
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            cardCount.toString(),
            style: context.theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.add, size: 18),
            onPressed: () async {
              await context.pushNamed(
                'addCard',
                pathParameters: {'deckId': deck.id!},
              );
            },
            tooltip: context.l10n.addCard,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(24, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.style,
            size: 16,
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.style, size: 16, color: context.theme.colorScheme.error),
          const SizedBox(width: 4),
          Icon(
            Icons.error_outline,
            size: 16,
            color: context.theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}
