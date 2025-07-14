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
                child: Text(
                  context.l10n.docContentLength(state.content!.length),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
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
