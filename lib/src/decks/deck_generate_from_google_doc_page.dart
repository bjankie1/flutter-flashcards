import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_generate_from_google_doc_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:logger/logger.dart';

import 'google_doc_picker.dart';

final _log = Logger();

class DeckGenerateFromGoogleDocPage extends ConsumerWidget {
  final model.DeckId? deckId;

  const DeckGenerateFromGoogleDocPage({super.key, this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      title: Text(context.l10n.generateFromGoogleDoc),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GoogleDocImportWidget(deckId: deckId),
      ),
    );
  }
}

class GoogleDocImportWidget extends ConsumerWidget {
  final model.DeckId? deckId;

  const GoogleDocImportWidget({super.key, this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(googleDocImportControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.generateFromGoogleDoc,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                icon: const Icon(Icons.description_outlined),
                label: Text(context.l10n.selectGoogleDoc),
                onPressed: () => _selectAndProcessDoc(context, ref),
              ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              _ErrorMessageContainer(state: state),
            ],
            if (state.content != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.docContentLength(state.content!.length),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: state.content!),
                            );
                            if (context.mounted) {
                              context.showInfoSnackbar(
                                'Content copied to clipboard',
                              );
                            }
                          },
                          tooltip: 'Copy content',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          state.content!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(context.l10n.generateFlashcards),
                        onPressed: () => _generateFlashcards(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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

    // TODO: Implement flashcard generation from content
    // This would typically involve:
    // 1. Sending the content to a flashcard generation service
    // 2. Processing the generated cards
    // 3. Adding them to the selected deck or creating a new deck

    if (context.mounted) {
      context.showInfoSnackbar('Flashcard generation feature coming soon!');
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
