import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../common/async_operation_handler.dart';
import '../../common/snackbar_messaging.dart';
import '../../common/build_context_extensions.dart';
import '../../genkit/functions.dart';
import 'card_descriptions_dialog_controller.dart';

/// Dialog for managing card descriptions
class CardDescriptionsDialog extends ConsumerStatefulWidget {
  final model.Deck deck;

  const CardDescriptionsDialog({super.key, required this.deck});

  @override
  ConsumerState<CardDescriptionsDialog> createState() =>
      _CardDescriptionsDialogState();
}

class _CardDescriptionsDialogState extends ConsumerState<CardDescriptionsDialog>
    with AsyncOperationHandler {
  final Logger _log = Logger();
  late TextEditingController _frontController;
  late TextEditingController _backController;
  late TextEditingController _explanationController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController();
    _backController = TextEditingController();
    _explanationController = TextEditingController();
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deckDetailsAsync = ref.watch(
      cardDescriptionsDialogControllerProvider(widget.deck.id!),
    );
    final controller = ref.read(
      cardDescriptionsDialogControllerProvider(widget.deck.id!).notifier,
    );

    return deckDetailsAsync.when(
      data: (currentDeck) {
        // Update controllers with current values
        _frontController.text = currentDeck.frontCardDescription ?? '';
        _backController.text = currentDeck.backCardDescription ?? '';
        _explanationController.text = currentDeck.explanationDescription ?? '';

        return AlertDialog(
          title: Text(context.l10n.cardDescriptions),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generate descriptions button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.generateCardDescriptions,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ElevatedButton.icon(
                        onPressed: controller.isGeneratingDescriptions
                            ? null
                            : () => _generateCardDescriptions(
                                context,
                                controller,
                              ),
                        icon: controller.isGeneratingDescriptions
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          currentDeck.frontCardDescription?.isNotEmpty ==
                                      true ||
                                  currentDeck.backCardDescription?.isNotEmpty ==
                                      true ||
                                  currentDeck
                                          .explanationDescription
                                          ?.isNotEmpty ==
                                      true
                              ? context.l10n.regenerateCardDescriptions
                              : context.l10n.generateCardDescriptions,
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Front card description field
                  TextFormField(
                    controller: _frontController,
                    decoration: InputDecoration(
                      labelText: context.l10n.frontCardDescriptionLabel,
                      hintText: context.l10n.frontCardDescriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Back card description field
                  TextFormField(
                    controller: _backController,
                    decoration: InputDecoration(
                      labelText: context.l10n.backCardDescriptionLabel,
                      hintText: context.l10n.backCardDescriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Explanation description field
                  TextFormField(
                    controller: _explanationController,
                    decoration: InputDecoration(
                      labelText: context.l10n.explanationDescriptionLabel,
                      hintText: context.l10n.explanationDescriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => _saveDescriptions(context, controller),
              child: Text(context.l10n.saveButton),
            ),
          ],
        );
      },
      loading: () => const AlertDialog(
        content: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        _log.e(
          'Error loading deck details for dialog',
          error: error,
          stackTrace: stackTrace,
        );
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error loading deck details: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateCardDescriptions(
    BuildContext context,
    CardDescriptionsDialogController controller,
  ) async {
    try {
      final result = await controller.generateCardDescriptions(context);
      _showGeneratedDescriptionsDialog(context, result, controller);
    } catch (e) {
      context.showErrorSnackbar('Error generating descriptions: $e');
    }
  }

  void _showGeneratedDescriptionsDialog(
    BuildContext context,
    CardDescriptionResult result,
    CardDescriptionsDialogController controller,
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
              _applyGeneratedDescriptions(context, result, controller);
            },
            child: Text(context.l10n.apply),
          ),
        ],
      ),
    );
  }

  Future<void> _applyGeneratedDescriptions(
    BuildContext context,
    CardDescriptionResult result,
    CardDescriptionsDialogController controller,
  ) async {
    try {
      if (result.frontCardDescription != null) {
        _frontController.text = result.frontCardDescription!;
      }
      if (result.backCardDescription != null) {
        _backController.text = result.backCardDescription!;
      }
      if (result.explanationDescription != null) {
        _explanationController.text = result.explanationDescription!;
      }

      context.showInfoSnackbar(context.l10n.cardDescriptionsAppliedMessage);
    } catch (e) {
      context.showErrorSnackbar(context.l10n.cardDescriptionsApplyErrorMessage);
    }
  }

  Future<void> _saveDescriptions(
    BuildContext context,
    CardDescriptionsDialogController controller,
  ) async {
    try {
      await executeWithFeedback(
        context: context,
        operation: () async {
          await controller.updateFrontCardDescription(
            _frontController.text.trim(),
            context.cloudFunctions,
          );
          await controller.updateBackCardDescription(
            _backController.text.trim(),
            context.cloudFunctions,
          );
          await controller.updateExplanationDescription(
            _explanationController.text.trim(),
          );
        },
        successMessage: context.l10n.cardDescriptionsConfigured,
        errorMessage: 'Error saving card descriptions',
        logErrorPrefix: 'Error saving card descriptions',
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling is done in executeWithFeedback
    }
  }
}
