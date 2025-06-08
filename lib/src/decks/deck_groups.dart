import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_group.dart';
import 'package:flutter_flashcards/src/decks/deck_list_item.dart';
import 'package:flutter_flashcards/src/model/cards.dart' show Deck, DeckGroup;
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:go_router/go_router.dart';

class DeckGroups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.cardRepository.decksGroupUpdated,
      builder: (context, _, __) => RepositoryLoader(
        fetcher: (repository) => repository.loadDecksInGroups(),
        builder: (context, groups, _) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                for (final (group, decks) in groups) ...[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _DeckGroupHeaderDelegate(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: group == null
                                  ? Text(
                                      context.l10n.decksWithoutGroupHeader,
                                      style: context.textTheme.headlineSmall,
                                    )
                                  : EditableText(
                                      text: group!.name,
                                      style: context.textTheme.headlineSmall,
                                      onTextChanged: (value) {
                                        context.cardRepository.updateDeckGroup(
                                          group!.copyWith(name: value),
                                        );
                                      },
                                    ),
                            ),
                            if (group != null)
                              DeckGroupReviewButton(deckGroup: group!),
                          ],
                        ),
                      ),
                      height: 56,
                    ),
                  ),
                  if (decks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 0,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < decks.length; i++) ...[
                                if (i > 0) Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: DeckListItem(deck: decks[i]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                SliverToBoxAdapter(
                  child: RepositoryLoader(
                    fetcher: (repository) => repository.listSharedDecks(),
                    builder: (context, sharedDecks, _) {
                      if (sharedDecks.isEmpty) return SizedBox.shrink();
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              context.l10n.sharedDecksHeader,
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                          ...sharedDecks.values
                              .expand((d) => d)
                              .map(
                                (deck) => CardsContainer(
                                  secondary: true,
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: DeckListItem(deck: deck),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _DeckGroupHeaderDelegate({required this.child, this.height = 56});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _DeckGroupHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class DeckGroupWidget extends StatelessWidget {
  final DeckGroup? group;

  final List<Deck> decks;

  const DeckGroupWidget({super.key, this.group, required this.decks});

  @override
  Widget build(BuildContext context) {
    return CardsContainer(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              group == null
                  ? Text(
                      context.l10n.decksWithoutGroupHeader,
                      style: context.textTheme.headlineMedium,
                    )
                  : EditableText(
                      text: group!.name,
                      style: context.textTheme.headlineMedium,
                      onTextChanged: (value) {
                        context.cardRepository.updateDeckGroup(
                          group!.copyWith(name: value),
                        );
                      },
                    ),
              if (group != null) DeckGroupReviewButton(deckGroup: group!),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 120),
            child: DeckGroupHorizontalList(decks: decks),
          ),
        ],
      ),
    );
  }
}

class DeckGroupReviewButton extends StatelessWidget {
  final DeckGroup deckGroup;

  const DeckGroupReviewButton({super.key, required this.deckGroup});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) =>
          repository.cardsToReviewCount(deckGroupId: deckGroup.id),
      builder: (context, countStat, _) {
        final count = countStat.values.fold(0, (p, c) => p + c);
        return Visibility(
          visible: count > 0,
          child: ElevatedButton.icon(
            onPressed: () async =>
                await context.push('/learn?deckGroupId=${deckGroup.id}'),
            icon: Icon(Icons.play_circle_fill),
            label: Text(context.l10n.cardsToReview(count)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: context.textTheme.labelLarge,
            ),
          ),
        );
      },
    );
  }
}

class EditableText extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;
  final TextStyle? style;

  const EditableText({
    super.key,
    required this.text,
    required this.onTextChanged,
    this.style,
  });

  @override
  State<EditableText> createState() => _EditableTextState();
}

class _EditableTextState extends State<EditableText> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool editing = false;
  bool hovering = false;
  String? originalText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
    focusNode = FocusNode();
    focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!focusNode.hasFocus && editing) {
      setState(() {
        editing = false;
        controller.text = originalText ?? widget.text;
      });
      focusNode.unfocus();
    }
  }

  void _startEditing() {
    setState(() {
      editing = true;
      originalText = widget.text;
      controller.text = widget.text;
      focusNode.requestFocus();
    });
  }

  void _save() {
    widget.onTextChanged(controller.text);
    setState(() {
      editing = false;
    });
  }

  void _cancel() {
    setState(() {
      editing = false;
      controller.text = originalText ?? widget.text;
    });
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;

    final borderColor = editing
        ? outline.withOpacity(0.7)
        : (hovering ? outline.withOpacity(0.5) : Colors.transparent);
    final borderWidth = editing ? 1.0 : (hovering ? 1.0 : 1.0);
    final fillColor = editing ? primary.withOpacity(0.08) : Colors.transparent;

    Widget textField = TextField(
      focusNode: focusNode,
      readOnly: !editing,
      controller: controller,
      style: widget.style,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      onTap: _startEditing,
      onSubmitted: (value) {
        _save();
      },
    );

    textField = MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        child: textField,
      ),
    );

    if (editing) {
      textField = Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) {
                _cancel();
                return null;
              },
            ),
          },
          child: textField,
        ),
      );
    }

    return Row(
      children: [
        Flexible(child: textField),
        if (editing)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Material(
              color: primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _save,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DismissIntent extends Intent {
  const DismissIntent();
}
