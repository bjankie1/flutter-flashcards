import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_router.dart';
import 'package:flutter_flashcards/src/common/async_operation_handler.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_list/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeckActionButtons extends SliverPersistentHeaderDelegate {
  final String deckId;

  const DeckActionButtons({required this.deckId});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8.0,
        children: [
          _LearnButtonWidget(deckId: deckId),
          _GenerateFromGoogleDocButtonWidget(deckId: deckId),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 36.0;

  @override
  double get minExtent => 36.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// Widget for the learn button with review count badge
final class _LearnButtonWidget extends ConsumerWidget
    with AsyncOperationHandler {
  final String deckId;

  _LearnButtonWidget({required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deckId));

    return cardCountAsync.when(
      data: (totalCards) {
        if (totalCards == 0) return const SizedBox.shrink();

        final cardsToReviewAsync = ref.watch(
          deckCardsToReviewControllerProvider(deckId),
        );

        return cardsToReviewAsync.when(
          data: (countStat) {
            final count = countStat.values.fold(0, (p, c) => p + c);
            return Badge(
              isLabelVisible: count > 0,
              label: Text(count.toString()),
              child: ElevatedButton.icon(
                onPressed: () {
                  executeNavigation(
                    context: context,
                    operation: () {
                      AppNavigation.goToLearn(context, deckId);
                    },
                    errorMessage: context.l10n.errorLoadingCards,
                  );
                },
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 24,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    context.l10n.learn,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            );
          },
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stackTrace) => ElevatedButton.icon(
            onPressed: () {
              executeNavigation(
                context: context,
                operation: () {
                  AppNavigation.goToLearn(context, deckId);
                },
                errorMessage: context.l10n.errorLoadingCards,
              );
            },
            icon: const Icon(Icons.play_circle_fill),
            label: Text(context.l10n.learn),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

/// Widget for the generate from Google Doc button
final class _GenerateFromGoogleDocButtonWidget extends ConsumerWidget
    with AsyncOperationHandler {
  final String deckId;

  _GenerateFromGoogleDocButtonWidget({required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        executeNavigation(
          context: context,
          operation: () {
            AppNavigation.goToGenerateFromGoogleDoc(context, deckId: deckId);
          },
          errorMessage: context.l10n.errorLoadingCards,
        );
      },
      icon: const Icon(Icons.description, color: Colors.white, size: 24),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          context.l10n.generateFromGoogleDoc,
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}
