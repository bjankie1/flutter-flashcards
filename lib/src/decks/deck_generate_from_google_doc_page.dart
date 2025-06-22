import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_generate_from_google_doc_controller.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'google_doc_picker.dart';

final _log = Logger();

class DeckGenerateFromGoogleDocPage extends StatelessWidget {
  final model.DeckId? deckId;

  const DeckGenerateFromGoogleDocPage({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoogleDocImportController(),
      child: BaseLayout(
        title: Text(context.l10n.generateFromGoogleDoc),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GoogleDocImportWidget(deckId: deckId),
        ),
      ),
    );
  }
}

class GoogleDocImportWidget extends StatelessWidget {
  final model.DeckId? deckId;

  const GoogleDocImportWidget({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GoogleDocImportController>();

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
            if (controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                icon: const Icon(Icons.description_outlined),
                label: Text('Select Google Doc'),
                onPressed: () => _selectAndProcessDoc(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAndProcessDoc(BuildContext context) async {
    final docId = await showDialog<String>(
      context: context,
      builder: (context) => GoogleDocPicker(),
    );

    if (docId == null || !context.mounted) return;

    final controller = context.read<GoogleDocImportController>();
    try {
      final content = await controller.processGoogleDoc(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doc content length: ${content.length}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      _log.e('Error processing google doc', error: e, stackTrace: st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
