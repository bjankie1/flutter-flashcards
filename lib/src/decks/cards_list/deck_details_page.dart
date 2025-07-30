import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_action_buttons.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/decks/cards_list/cards_list.dart';
import 'package:flutter_flashcards/src/decks/cards_list/cards_list_controller.dart';

import 'package:flutter_flashcards/src/decks/cards_list/deck_details_controller.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details_page_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';

import '../../model/cards.dart' as model;

class DeckDetailsPage extends ConsumerWidget {
  final model.Deck deck;

  const DeckDetailsPage({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      title: Text(deck.name),
      currentPage: PageIndex.cards,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref
            .read(deckDetailsPageControllerProvider.notifier)
            .navigateToAddCard(context, deck.id!),
        label: Text(context.l10n.addCard),
        icon: const Icon(Icons.add),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                DeckDetails(deck: deck),
                Expanded(child: _DeckDetailsSliverView(deck: deck)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckDetailsSliverView extends ConsumerWidget {
  final model.Deck deck;

  const _DeckDetailsSliverView({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(cardsListControllerProvider(deck.id!));
    final controller = ref.read(cardsListControllerProvider(deck.id!).notifier);

    return CustomScrollView(
      slivers: [
        // SliverAppBar with FlexibleSpaceBar for deck details and description fields
        SliverAppBar(
          pinned: false,
          expandedHeight: 200.0,
          collapsedHeight: 80.0,
          automaticallyImplyLeading: false,
          // title: Text(deck.name),
          flexibleSpace: FlexibleSpaceBar(
            background: _CardDescriptionFieldsCompact(deck: deck),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: DeckActionButtons(deckId: deck.id!),
        ),

        // Search field as persistent header
        controllerState.when(
          data: (data) => _SearchField(
            searchQuery: data.searchQuery,
            onSearchChanged: controller.updateSearchQuery,
          ),
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Cards list section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: CardsList(deck: deck),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _SearchField({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchFieldDelegate(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchFieldDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _SearchFieldDelegate({required this.child});

  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// Compact version of card description fields for SliverAppBar
class _CardDescriptionFieldsCompact extends ConsumerWidget {
  final model.Deck deck;

  const _CardDescriptionFieldsCompact({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckDetailsAsync = ref.watch(deckDetailsControllerProvider(deck.id!));
    final controllerNotifier = ref.read(
      deckDetailsControllerProvider(deck.id!).notifier,
    );

    return deckDetailsAsync.when(
      data: (currentDeck) {
        final hasAnyDescription =
            currentDeck.frontCardDescription?.isNotEmpty == true ||
            currentDeck.backCardDescription?.isNotEmpty == true ||
            currentDeck.explanationDescription?.isNotEmpty == true;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cardDescriptions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controllerNotifier.isGeneratingDescriptions
                        ? null
                        : () => _generateCardDescriptions(
                            context,
                            controllerNotifier,
                          ),
                    icon: controllerNotifier.isGeneratingDescriptions
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 16),
                    label: Text(
                      hasAnyDescription
                          ? context.l10n.regenerateCardDescriptions
                          : context.l10n.generateCardDescriptions,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildCompactDescriptionFields(
                context,
                controllerNotifier,
                currentDeck,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading deck details: $error')),
    );
  }

  Widget _buildCompactDescriptionFields(
    BuildContext context,
    dynamic controllerNotifier,
    model.Deck currentDeck,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactDescriptionField(
          text: currentDeck.frontCardDescription,
          label: context.l10n.frontCardDescriptionLabel,
          onTextChanged: (value) => controllerNotifier
              .updateFrontCardDescription(value, context.cloudFunctions),
        ),
        const SizedBox(height: 4),
        _CompactDescriptionField(
          text: currentDeck.backCardDescription,
          label: context.l10n.backCardDescriptionLabel,
          onTextChanged: (value) => controllerNotifier
              .updateBackCardDescription(value, context.cloudFunctions),
        ),
        const SizedBox(height: 4),
        _CompactDescriptionField(
          text: currentDeck.explanationDescription,
          label: context.l10n.explanationDescriptionLabel,
          onTextChanged: (value) =>
              controllerNotifier.updateExplanationDescription(value),
        ),
      ],
    );
  }

  Future<void> _generateCardDescriptions(
    BuildContext context,
    dynamic controllerNotifier,
  ) async {
    try {
      final result = await controllerNotifier.generateCardDescriptions(context);
      // Show a dialog with the generated descriptions
      _showGeneratedDescriptionsDialog(context, result, controllerNotifier);
    } catch (e) {
      context.showErrorSnackbar('Error generating descriptions: $e');
    }
  }

  void _showGeneratedDescriptionsDialog(
    BuildContext context,
    dynamic result,
    dynamic controllerNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.generatedCardDescriptions),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.confidenceLevel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text('${(result.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              Text(
                context.l10n.analysis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(result.analysis),
              const SizedBox(height: 16),
              if (result.frontCardDescription != null) ...[
                Text(
                  context.l10n.frontCardDescriptionLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(result.frontCardDescription!),
                const SizedBox(height: 16),
              ],
              if (result.backCardDescription != null) ...[
                Text(
                  context.l10n.backCardDescriptionLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(result.backCardDescription!),
                const SizedBox(height: 16),
              ],
              if (result.explanationDescription != null) ...[
                Text(
                  context.l10n.explanationDescriptionLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(result.explanationDescription!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyGeneratedDescriptions(context, result, controllerNotifier);
            },
            child: Text(context.l10n.apply),
          ),
        ],
      ),
    );
  }

  Future<void> _applyGeneratedDescriptions(
    BuildContext context,
    dynamic result,
    dynamic controllerNotifier,
  ) async {
    try {
      if (result.frontCardDescription != null) {
        await controllerNotifier.updateFrontCardDescription(
          result.frontCardDescription!,
          context.cloudFunctions,
        );
      }
      if (result.backCardDescription != null) {
        await controllerNotifier.updateBackCardDescription(
          result.backCardDescription!,
          context.cloudFunctions,
        );
      }
      if (result.explanationDescription != null) {
        await controllerNotifier.updateExplanationDescription(
          result.explanationDescription!,
        );
      }
      context.showInfoSnackbar(context.l10n.cardDescriptionsAppliedMessage);
    } catch (e) {
      context.showErrorSnackbar(context.l10n.cardDescriptionsApplyErrorMessage);
    }
  }
}

/// Compact description field widget
class _CompactDescriptionField extends StatelessWidget {
  final String? text;
  final String label;
  final Function(String) onTextChanged;

  const _CompactDescriptionField({
    this.text,
    required this.label,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text != null && text!.isNotEmpty;

    if (!hasText) {
      return OutlinedButton.icon(
        onPressed: () => _showEditDialog(context),
        icon: const Icon(Icons.add, size: 12),
        label: Text('Add $label', style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(0, 24),
        ),
      );
    }

    return InkWell(
      onTap: () => _showEditDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.edit, size: 12),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: text ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              onTextChanged(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
