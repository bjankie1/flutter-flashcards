import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_cards_add.dart';
import 'package:flutter_flashcards/src/decks/provisionary_cards/provisionary_cards_review_controller.dart';
import 'package:flutter_flashcards/src/app_router.dart';
import 'package:go_router/go_router.dart';

/// Widget containing the action buttons for quick add and review provisionary cards
class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provisionaryCardsAsync = ref.watch(
      provisionaryCardsReviewControllerProvider,
    );

    return provisionaryCardsAsync.when(
      data: (data) {
        final provisionaryCardsCount = data.unprocessedCardsCount;
        final hasCardsToReview = provisionaryCardsCount > 0;

        return Container(
          height: 36, // Slightly smaller than SegmentedButton default height
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(
              18,
            ), // Adjusted border radius to match new height
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick add button - larger with label
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  onTap: () => _showQuickAddDialog(context),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_box, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.quickAddCard,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 24,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              // Review provisionary cards button - smaller, icon only
              SizedBox(
                width: 48, // Fixed width for icon-only button
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    onTap: hasCardsToReview
                        ? () => context.pushNamed(NamedRoute.quickCards.name)
                        : null,
                    child: Stack(
                      children: [
                        Container(
                          height: 36,
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.checklist,
                            size: 20,
                            color: hasCardsToReview
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        if (hasCardsToReview)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                provisionaryCardsCount.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 120,
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => const SizedBox(
        width: 120,
        height: 40,
        child: Icon(Icons.error_outline),
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ProvisionaryCardAdd();
      },
    );
  }
}
