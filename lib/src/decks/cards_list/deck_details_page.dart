import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_list/index.dart';
import 'package:flutter_flashcards/src/app_router.dart';
import 'package:flutter_flashcards/src/common/async_operation_handler.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details.dart';
import 'package:flutter_flashcards/src/decks/cards_list/cards_list_controller.dart';
import 'package:flutter_flashcards/src/decks/cards_list/cards_list_widgets.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details_page_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';

import '../../model/cards.dart' as model;
import 'package:flutter_flashcards/src/decks/cards_list/card_descriptions_dialog.dart';

class DeckDetailsPage extends ConsumerWidget {
  final model.Deck deck;

  const DeckDetailsPage({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      title: Text(deck.name),
      currentPage: PageIndex.cards,
      onCardDescriptions: () => _showCardDescriptionsDialog(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref
            .read(deckDetailsPageControllerProvider.notifier)
            .navigateToAddCard(context, deck.id!),
        label: Text(context.l10n.addCard),
        icon: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          // Deck details section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deck name
                DeckDetails(deck: deck),
                const SizedBox(height: 16),
                // Deck action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LearnButtonWidget(deckId: deck.id!),
                    const SizedBox(width: 8),
                    _GenerateFromGoogleDocButtonWidget(deckId: deck.id!),
                  ],
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _SearchField(deckId: deck.id!),
          ),
          // Scrollable cards list
          Expanded(child: _CardsListRegular(deck: deck)),
        ],
      ),
    );
  }

  void _showCardDescriptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CardDescriptionsDialog(deck: deck),
    );
  }
}

/// Regular (non-sliver) version of cards list for use in Column
class _CardsListRegular extends ConsumerWidget {
  final model.Deck deck;

  const _CardsListRegular({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(cardsListControllerProvider(deck.id!));
    final controller = ref.read(cardsListControllerProvider(deck.id!).notifier);

    return controllerState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.l10n.errorLoadingCards),
            ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
      data: (data) {
        final filteredCards = data.filteredCards;
        final hasCards = filteredCards.isNotEmpty;

        if (!hasCards) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(context.l10n.noCardsMessage),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: filteredCards.length,
          itemBuilder: (context, index) {
            final card = filteredCards[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CardTile(
                    deck: deck,
                    card: card,
                    cardStats: data.cardStats[card.id] ?? [],
                    onDelete: () => controller.deleteCard(card),
                  ),
                ),
                if (index < filteredCards.length - 1) const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

/// Search field widget
class _SearchField extends ConsumerStatefulWidget {
  final String deckId;

  const _SearchField({required this.deckId});

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final controller = ref.read(
      cardsListControllerProvider(widget.deckId).notifier,
    );
    controller.updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(
      cardsListControllerProvider(widget.deckId),
    );

    return controllerState.when(
      data: (data) => TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.cardsSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
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
