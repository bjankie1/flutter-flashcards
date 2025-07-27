import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/async_operation_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';

import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/common/category_image.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:logger/logger.dart';

import '../../model/cards.dart' as model;
import '../../common/editable_text.dart' as custom;
import '../../app_router.dart';
import '../../genkit/functions.dart';
import 'deck_details_controller.dart';
import '../deck_list/deck_info_controller.dart';
import '../deck_list/deck_cards_to_review_controller.dart';

/// Shows Deck metadata information enabling user to edit those details.
final class DeckDetails extends ConsumerWidget {
  final Logger _log = Logger();

  final model.Deck deck;

  DeckDetails({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckDetailsAsync = ref.watch(deckDetailsControllerProvider(deck.id!));
    final controller = ref.read(
      deckDetailsControllerProvider(deck.id!).notifier,
    );

    return deckDetailsAsync.when(
      data: (currentDeck) => _DeckDetailsContent(
        deck: deck,
        currentDeck: currentDeck,
        controller: controller,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        _log.e(
          'Error loading deck details',
          error: error,
          stackTrace: stackTrace,
        );
        return _ErrorDisplayWidget(deck: deck);
      },
    );
  }
}

class _ErrorDisplayWidget extends ConsumerWidget {
  const _ErrorDisplayWidget({required this.deck});

  final model.Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: context.theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading deck details',
            style: context.theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                ref.refresh(deckDetailsControllerProvider(deck.id!)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Content widget for displaying and editing deck details
final class _DeckDetailsContent extends ConsumerWidget
    with AsyncOperationHandler {
  final model.Deck deck;
  final model.Deck currentDeck;
  final DeckDetailsController controller;

  _DeckDetailsContent({
    required this.deck,
    required this.currentDeck,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom.EditableText(
          text: currentDeck.name,
          style: context.theme.textTheme.headlineSmall,
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () =>
                controller.updateDeckName(value, context.cloudFunctions),
            successMessage: context.l10n.deckNameSavedMessage,
            errorMessage: context.l10n.deckDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving deck name',
          ),
        ),
        custom.EditableText(
          text: currentDeck.description ?? '',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.isDarkTheme
                ? context.theme.colorScheme.onSurface.darken(30)
                : context.theme.colorScheme.onSurface.lighten(30),
          ),
          placeholder: 'Add description',
          onTextChanged: (value) => executeWithFeedback(
            context: context,
            operation: () =>
                controller.updateDeckDescription(value, context.cloudFunctions),
            successMessage: context.l10n.deckDescriptionSavedMessage,
            errorMessage: context.l10n.deckDescriptionSaveErrorMessage,
            logErrorPrefix: 'Error saving deck description',
          ),
        ),

        _CardDescriptionFields(deck: currentDeck),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LearnButtonWidget(deckId: deck.id!),
              const SizedBox(width: 16),
              _GenerateFromGoogleDocButtonWidget(deckId: deck.id!),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying the card count
final class _CardCountWidget extends ConsumerWidget {
  final String deckId;

  const _CardCountWidget({required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardCountAsync = ref.watch(deckInfoControllerProvider(deckId));

    return cardCountAsync.when(
      data: (totalCards) => Text(
        "${context.l10n.cards}: $totalCards",
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => Text(
        "${context.l10n.cards}: 0",
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
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

class _CardDescriptionFields extends ConsumerWidget with AsyncOperationHandler {
  final model.Deck deck;

  _CardDescriptionFields({required this.deck});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerNotifier = ref.read(
      deckDetailsControllerProvider(deck.id!).notifier,
    );
    final hasAnyDescription =
        deck.frontCardDescription?.isNotEmpty == true ||
        deck.backCardDescription?.isNotEmpty == true ||
        deck.explanationDescription?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with expand/collapse only
        Material(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.cardDescriptions,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    // Generate button inside the collapsible container
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
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        hasAnyDescription
                            ? context.l10n.regenerateCardDescriptions
                            : context.l10n.generateCardDescriptions,
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                _buildDescriptionFields(context, controllerNotifier),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionFields(
    BuildContext context,
    DeckDetailsController controllerNotifier,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DescriptionField(
            text: deck.frontCardDescription,
            onTextChanged: (value) async {
              try {
                await executeWithFeedback(
                  context: context,
                  operation: () =>
                      controllerNotifier.updateFrontCardDescription(
                        value,
                        context.cloudFunctions,
                      ),
                  successMessage: context.l10n.frontCardDescriptionSavedMessage,
                  errorMessage:
                      context.l10n.frontCardDescriptionSaveErrorMessage,
                  logErrorPrefix: 'Error saving front card description',
                );
              } catch (e) {
                // Error handling is done in executeWithFeedback
              }
            },
            addButtonText: context.l10n.addFrontCardDescription,
            label: context.l10n.frontCardDescriptionLabel,
            hint: context.l10n.frontCardDescriptionHint,
          ),
          const SizedBox(height: 12),
          _DescriptionField(
            text: deck.backCardDescription,
            onTextChanged: (value) async {
              try {
                await executeWithFeedback(
                  context: context,
                  operation: () => controllerNotifier.updateBackCardDescription(
                    value,
                    context.cloudFunctions,
                  ),
                  successMessage: context.l10n.backCardDescriptionSavedMessage,
                  errorMessage:
                      context.l10n.backCardDescriptionSaveErrorMessage,
                  logErrorPrefix: 'Error saving back card description',
                );
              } catch (e) {
                // Error handling is done in executeWithFeedback
              }
            },
            addButtonText: context.l10n.addBackCardDescription,
            label: context.l10n.backCardDescriptionLabel,
            hint: context.l10n.backCardDescriptionHint,
          ),
          const SizedBox(height: 12),
          _DescriptionField(
            text: deck.explanationDescription,
            onTextChanged: (value) async {
              try {
                await executeWithFeedback(
                  context: context,
                  operation: () =>
                      controllerNotifier.updateExplanationDescription(value),
                  successMessage:
                      context.l10n.explanationDescriptionSavedMessage,
                  errorMessage:
                      context.l10n.explanationDescriptionSaveErrorMessage,
                  logErrorPrefix: 'Error saving explanation description',
                );
              } catch (e) {
                // Error handling is done in executeWithFeedback
              }
            },
            addButtonText: context.l10n.addExplanationDescription,
            label: context.l10n.explanationDescriptionLabel,
            hint: context.l10n.explanationDescriptionHint,
          ),
        ],
      ),
    );
  }

  Future<void> _generateCardDescriptions(
    BuildContext context,
    DeckDetailsController controllerNotifier,
  ) async {
    try {
      final result = await controllerNotifier.generateCardDescriptions(context);

      // Show a dialog with the generated descriptions and analysis
      _showGeneratedDescriptionsDialog(context, result, controllerNotifier);
    } catch (e) {
      // Error handling is done in the controller
      context.showErrorSnackbar('Error generating descriptions: $e');
    }
  }

  void _showGeneratedDescriptionsDialog(
    BuildContext context,
    CardDescriptionResult result,
    DeckDetailsController controllerNotifier,
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
                style: context.theme.textTheme.titleSmall,
              ),
              Text('${(result.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              Text(
                context.l10n.analysis,
                style: context.theme.textTheme.titleSmall,
              ),
              Text(result.analysis),
              const SizedBox(height: 16),
              if (result.frontCardDescription != null) ...[
                Text(
                  context.l10n.frontCardDescriptionLabel,
                  style: context.theme.textTheme.titleSmall,
                ),
                Text(result.frontCardDescription!),
                const SizedBox(height: 16),
              ],
              if (result.backCardDescription != null) ...[
                Text(
                  context.l10n.backCardDescriptionLabel,
                  style: context.theme.textTheme.titleSmall,
                ),
                Text(result.backCardDescription!),
                const SizedBox(height: 16),
              ],
              if (result.explanationDescription != null) ...[
                Text(
                  context.l10n.explanationDescriptionLabel,
                  style: context.theme.textTheme.titleSmall,
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
    CardDescriptionResult result,
    DeckDetailsController controllerNotifier,
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

/// Internal widget for collapsible description field
class _DescriptionField extends StatefulWidget {
  final String? text;
  final Function(String) onTextChanged;
  final String addButtonText;
  final String label;
  final String hint;

  const _DescriptionField({
    this.text,
    required this.onTextChanged,
    required this.addButtonText,
    required this.label,
    required this.hint,
  });

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool isEditing = false;
  String? _originalText;

  @override
  void initState() {
    super.initState();
    _originalText = widget.text;
    controller = TextEditingController(text: widget.text ?? '');
    focusNode = FocusNode();
    focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(_DescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _originalText = widget.text;
      controller.text = widget.text ?? '';
      isEditing = false;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!focusNode.hasFocus && isEditing) {
      setState(() {
        isEditing = false;
      });
    }
  }

  bool get _hasUnsavedChanges {
    final currentText = controller.text.trim();
    final originalText = _originalText ?? '';
    return currentText != originalText;
  }

  void _expandField() {
    setState(() {
      isEditing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _save() {
    final text = controller.text.trim();
    widget.onTextChanged(text);
    setState(() {
      _originalText = text;
      isEditing = false;
    });
  }

  void _cancel() {
    setState(() {
      isEditing = false;
      controller.text = _originalText ?? '';
    });
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final hasText = widget.text != null && widget.text!.isNotEmpty;

    if (!hasText && !isEditing) {
      return OutlinedButton.icon(
        onPressed: _expandField,
        icon: const Icon(Icons.add, size: 16),
        label: Text(widget.addButtonText),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: outline.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: theme.textTheme.bodyMedium,
          minLines: 1,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
            suffixIcon: _hasUnsavedChanges
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _cancel,
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Cancel',
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                      IconButton(
                        onPressed: _save,
                        icon: const Icon(Icons.check, size: 20),
                        tooltip: 'Save',
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          onFieldSubmitted: (value) => _save(),
          onChanged: (value) {
            setState(() {
              // Trigger rebuild to show/hide save/cancel buttons
            });
          },
        ),
      ],
    );
  }
}
