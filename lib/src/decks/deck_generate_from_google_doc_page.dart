import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_generate_from_google_doc_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:logger/logger.dart';

import 'google_doc_picker.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details_controller.dart';
import 'package:go_router/go_router.dart';

final _log = Logger();

class DeckGenerateFromGoogleDocPage extends ConsumerWidget {
  final model.DeckId? deckId;

  const DeckGenerateFromGoogleDocPage({super.key, this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(googleDocImportControllerProvider);
    final docLength = state.content?.length ?? 0;

    return BaseLayout(
      title: Text(context.l10n.generateFromGoogleDoc),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            expandedHeight: 0,
            collapsedHeight: 72,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final bool hasDoc = state.content != null;
                Widget? deckNameWidget;
                if (deckId != null) {
                  deckNameWidget = Consumer(
                    builder: (context, ref, _) {
                      final deckAsync = ref.watch(
                        deckDetailsControllerProvider(deckId!),
                      );
                      return deckAsync.when(
                        data: (deck) => Text(
                          deck.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => const SizedBox(
                          width: 60,
                          height: 16,
                          child: LinearProgressIndicator(),
                        ),
                        error: (e, st) => const SizedBox(),
                      );
                    },
                  );
                }
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: hasDoc && state.content != null
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Show content'),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            height: 400,
                                            child: SingleChildScrollView(
                                              child: SelectableText(
                                                state.content!,
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(
                                hasDoc
                                    ? (state.title ?? 'Untitled')
                                    : context.l10n.generateFromGoogleDoc,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: hasDoc
                                      ? TextDecoration.underline
                                      : null,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (deckNameWidget != null) ...[
                              const SizedBox(height: 2),
                              deckNameWidget,
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 44,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasDoc)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload new file'),
                                onPressed: () async {
                                  final controller = ref.read(
                                    googleDocImportControllerProvider.notifier,
                                  );
                                  controller.clearContent();
                                  await _selectAndProcessDoc(context, ref);
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(44, 44),
                                ),
                              ),
                            if (hasDoc) const SizedBox(width: 8),
                            hasDoc
                                ? FilledButton.icon(
                                    icon: const Icon(Icons.auto_awesome),
                                    label: Text(
                                      state.generatedFlashcards != null &&
                                              state
                                                  .generatedFlashcards!
                                                  .isNotEmpty
                                          ? 'Regenerate flashcards'
                                          : context.l10n.generateFlashcards,
                                    ),
                                    onPressed: state.isGeneratingFlashcards
                                        ? null
                                        : () =>
                                              _generateFlashcards(context, ref),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(44, 44),
                                    ),
                                  )
                                : FilledButton.icon(
                                    icon: const Icon(
                                      Icons.description_outlined,
                                    ),
                                    label: Text(context.l10n.selectGoogleDoc),
                                    onPressed: state.isLoading
                                        ? null
                                        : () => _selectAndProcessDoc(
                                            context,
                                            ref,
                                          ),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(44, 44),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.error != null) ...[
                    _ErrorMessageContainer(state: state),
                    const SizedBox(height: 16),
                  ],
                  if (state.content != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Doc length: $docLength',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.isGeneratingFlashcards) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 12),
                    ],
                  ],
                  if (state.isLoading && state.content == null) ...[
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
          if (state.generatedFlashcards != null)
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Generated Flashcards (${state.generatedFlashcards!.length})',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  final flashcard = state.generatedFlashcards![index - 1];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        flashcard.question,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        flashcard.answer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        if (flashcard.explanation != null) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explanation:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(flashcard.explanation!),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }, childCount: 1 + state.generatedFlashcards!.length),
              ),
            ),
          if (state.generatedFlashcards != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Cards'),
                        onPressed: () {
                          context.showInfoSnackbar('Edit feature coming soon!');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save to Deck'),
                        onPressed: () {
                          context.showInfoSnackbar('Save feature coming soon!');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectAndProcessDoc(BuildContext context, WidgetRef ref) async {
    final docId = await showDialog<String>(
      context: context,
      builder: (context) => GoogleDocPicker(),
    );

    if (docId == null || !context.mounted) return;

    final controller = ref.read(googleDocImportControllerProvider.notifier);
    try {
      final content = await controller.processGoogleDoc(docId);
      if (context.mounted) {
        context.showInfoSnackbar(context.l10n.docContentLength(content.length));
        // Do NOT pop the page here
      }
    } catch (e, st) {
      _log.e('Error processing google doc', error: e, stackTrace: st);
      if (context.mounted) {
        context.showErrorSnackbar(context.l10n.errorPrefix(e.toString()));
      }
    }
  }

  Future<void> _generateFlashcards(BuildContext context, WidgetRef ref) async {
    final state = ref.read(googleDocImportControllerProvider);
    if (state.content == null) return;

    try {
      final controller = ref.read(googleDocImportControllerProvider.notifier);
      await controller.generateFlashcards();

      if (context.mounted) {
        context.showInfoSnackbar(
          'Generated ${state.generatedFlashcards?.length ?? 0} flashcards!',
        );
      }
    } catch (e, st) {
      _log.e('Error generating flashcards', error: e, stackTrace: st);
      if (context.mounted) {
        context.showErrorSnackbar(context.l10n.errorPrefix(e.toString()));
      }
    }
  }
}

class _ErrorMessageContainer extends StatelessWidget {
  const _ErrorMessageContainer({required this.state});

  final GoogleDocImportState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        state.error!,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}
