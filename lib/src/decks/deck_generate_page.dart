import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_generate_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:logger/logger.dart';

import 'google_doc_picker.dart';
import 'package:flutter_flashcards/src/decks/cards_list/deck_details_controller.dart';

final _log = Logger();

class DeckGeneratePage extends ConsumerStatefulWidget {
  final model.DeckId? deckId;

  const DeckGeneratePage({super.key, this.deckId});

  @override
  ConsumerState<DeckGeneratePage> createState() => _DeckGeneratePageState();
}

class _DeckGeneratePageState extends ConsumerState<DeckGeneratePage> {
  @override
  void initState() {
    super.initState();
    // Reset the controller when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(generateControllerProvider.notifier);
      controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateControllerProvider);
    final hasContent = state.content != null || state.binaryData != null;

    // Debug logging for UI state
    if (state.binaryData != null) {
      _log.i(
        'UI: binaryData present, size: ${state.binaryData!.length} bytes, fileName: ${state.fileName}',
      );
    }
    if (state.content != null) {
      _log.i(
        'UI: content present, length: ${state.content!.length} characters',
      );
    }
    _log.i('UI: hasContent = $hasContent, isLoading = ${state.isLoading}');

    Widget? deckNameWidget;
    if (widget.deckId != null) {
      deckNameWidget = Consumer(
        builder: (context, ref, _) {
          final deckAsync = ref.watch(
            deckDetailsControllerProvider(widget.deckId!),
          );
          return deckAsync.when(
            data: (deck) => Text(
              deck.name,
              style: context.textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return BaseLayout(
      title: Text(context.l10n.generateCards),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            elevation: 2,
            toolbarHeight: 140,
            collapsedHeight: 140,
            expandedHeight: 140,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                height: 124,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: hasContent && state.content != null
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  context.l10n.showContent,
                                                ),
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
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                    child: Text(
                                                      context.l10n.close,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      hasContent
                                          ? (state.title ?? 'Untitled')
                                          : context.l10n.generateCards,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            decoration: hasContent
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
                                  if (state.content != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      context.l10n.docLength(
                                        state.content!.length,
                                      ),
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context).hintColor,
                                          ),
                                    ),
                                  ],
                                  if (state.binaryData != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      context.l10n.fileSize(
                                        state.binaryData!.length,
                                      ),
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context).hintColor,
                                          ),
                                    ),
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
                                  if (hasContent)
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.upload_file),
                                      label: Text(context.l10n.uploadNewFile),
                                      onPressed: () async {
                                        final controller = ref.read(
                                          generateControllerProvider.notifier,
                                        );
                                        controller.clearContent();
                                        await _showInputSourceDialog(
                                          context,
                                          ref,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(44, 44),
                                      ),
                                    ),
                                  if (hasContent) const SizedBox(width: 8),
                                  hasContent
                                      ? FilledButton.icon(
                                          icon: const Icon(Icons.auto_awesome),
                                          label: Text(
                                            state.generatedFlashcards != null &&
                                                    state
                                                        .generatedFlashcards!
                                                        .isNotEmpty
                                                ? context
                                                      .l10n
                                                      .regenerateFlashcards
                                                : context
                                                      .l10n
                                                      .generateFlashcards,
                                          ),
                                          onPressed:
                                              state.isGeneratingFlashcards
                                              ? null
                                              : () => _generateFlashcards(
                                                  context,
                                                  ref,
                                                ),
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size(44, 44),
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FilledButton.icon(
                                              icon: const Icon(Icons.add),
                                              label: Text(
                                                context.l10n.selectInputSource,
                                              ),
                                              onPressed: state.isLoading
                                                  ? null
                                                  : () =>
                                                        _showInputSourceDialog(
                                                          context,
                                                          ref,
                                                        ),
                                              style: FilledButton.styleFrom(
                                                minimumSize: const Size(44, 44),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              icon: const Icon(
                                                Icons.bug_report,
                                              ),
                                              label: const Text('Test'),
                                              onPressed: () async {
                                                final controller = ref.read(
                                                  generateControllerProvider
                                                      .notifier,
                                                );
                                                await controller
                                                    .testFilePicker();
                                              },
                                              style: OutlinedButton.styleFrom(
                                                minimumSize: const Size(44, 44),
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (state.error != null) ...[
                          const SizedBox(height: 16),
                          _ErrorMessageContainer(state: state),
                        ],
                        if (state.isGeneratingFlashcards) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (state.generatedFlashcards != null)
            _GeneratedCardsList(state: state),
          if (state.generatedFlashcards != null) _FinalActionsBar(),
        ],
      ),
    );
  }

  Future<void> _showInputSourceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<InputSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.selectInputSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(context.l10n.pasteText),
              onTap: () => Navigator.of(context).pop(InputSource.text),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(context.l10n.uploadPdf),
              onTap: () => Navigator.of(context).pop(InputSource.pdf),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text(context.l10n.uploadImage),
              onTap: () => Navigator.of(context).pop(InputSource.image),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(context.l10n.selectGoogleDoc),
              onTap: () => Navigator.of(context).pop(InputSource.googleDoc),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return;

    final controller = ref.read(generateControllerProvider.notifier);

    try {
      switch (result) {
        case InputSource.text:
          await _showTextInputDialog(context, ref);
          break;
        case InputSource.pdf:
        case InputSource.image:
          await controller.pickAndProcessFile(result);
          break;
        case InputSource.googleDoc:
          await _selectAndProcessGoogleDoc(context, ref);
          break;
      }
    } catch (e, st) {
      _log.e('Error processing input source', error: e, stackTrace: st);
      if (context.mounted) {
        context.showErrorSnackbar(context.l10n.errorPrefix(e.toString()));
      }
    }
  }

  Future<void> _showTextInputDialog(BuildContext context, WidgetRef ref) async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.pasteText),
        content: TextField(
          controller: textController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: context.l10n.pasteTextHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(textController.text),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return;

    final controller = ref.read(generateControllerProvider.notifier);
    try {
      await controller.setTextContent(result);
      if (context.mounted) {
        context.showInfoSnackbar(context.l10n.textContentLength(result.length));
      }
    } catch (e, st) {
      _log.e('Error processing text content', error: e, stackTrace: st);
      if (context.mounted) {
        context.showErrorSnackbar(context.l10n.errorPrefix(e.toString()));
      }
    }
  }

  Future<void> _selectAndProcessGoogleDoc(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final docId = await showDialog<String>(
      context: context,
      builder: (context) => GoogleDocPicker(),
    );

    if (docId == null || !context.mounted) return;

    final controller = ref.read(generateControllerProvider.notifier);
    try {
      await controller.processGoogleDoc(docId);
      if (context.mounted) {
        final currentState = ref.read(generateControllerProvider);
        context.showInfoSnackbar(
          context.l10n.docContentLength(currentState.content?.length ?? 0),
        );
      }
    } catch (e, st) {
      _log.e('Error processing google doc', error: e, stackTrace: st);
      if (context.mounted) {
        context.showErrorSnackbar(context.l10n.errorPrefix(e.toString()));
      }
    }
  }

  Future<void> _generateFlashcards(BuildContext context, WidgetRef ref) async {
    final state = ref.read(generateControllerProvider);
    if (state.source == null) return;

    try {
      final controller = ref.read(generateControllerProvider.notifier);
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

class _FinalActionsBar extends StatelessWidget {
  const _FinalActionsBar();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: Text(context.l10n.editCards),
                onPressed: () {
                  context.showInfoSnackbar('Edit feature coming soon!');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: Text(context.l10n.saveToDeck),
                onPressed: () {
                  context.showInfoSnackbar('Save feature coming soon!');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedCardsList extends StatelessWidget {
  const _GeneratedCardsList({required this.state});

  final GenerateState state;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                context.l10n.generatedFlashcards(
                  state.generatedFlashcards!.length,
                ),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          final flashcard = state.generatedFlashcards![index - 1];
          final isSelected = state.selectedFlashcardIndexes.contains(index - 1);
          final hasExplanation =
              flashcard.explanation != null &&
              flashcard.explanation!.trim().isNotEmpty;
          return Consumer(
            builder: (context, ref, _) => InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref
                    .read(generateControllerProvider.notifier)
                    .toggleFlashcardSelection(index - 1);
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: hasExplanation
                    ? ExpansionTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
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
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.explanationLabel,
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
                      )
                    : ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          flashcard.question,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          flashcard.answer,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ),
          );
        }, childCount: 1 + state.generatedFlashcards!.length),
      ),
    );
  }
}

class _ErrorMessageContainer extends StatelessWidget {
  const _ErrorMessageContainer({required this.state});

  final GenerateState state;

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
