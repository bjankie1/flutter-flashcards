import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/containers.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/decks/deck_group.dart';
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
        builder: (context, groups, _) => ListView(
          children: _groupsWidgets(context, groups),
        ),
      ),
    );
  }

  _groupsWidgets(BuildContext context, List<(DeckGroup?, List<Deck>)> groups) {
    return [
      ...groups.map((t) {
        final (group, decks) = t;
        return [
          DeckGroupWidget(group: group, decks: decks),
        ];
      }).expand((l) => l),
      RepositoryLoader(
          fetcher: (repository) => repository.listSharedDecks(),
          builder: (context, sharedDecks, _) {
            return Column(
              children: sharedDecks.isEmpty
                  ? []
                  : [
                      Text(
                        context.l10n.sharedDecksHeader,
                        style: context.textTheme.headlineMedium,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: DeckGroupHorizontalList(
                            decks:
                                sharedDecks.values.expand((d) => d).toList()),
                      ),
                    ],
            );
          })
    ];
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
                        context.cardRepository
                            .updateDeckGroup(group!.copyWith(name: value));
                      },
                    ),
              if (group != null)
                DeckGroupReviewButton(
                  deckGroup: group!,
                )
            ],
          ),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 120),
              child: DeckGroupHorizontalList(decks: decks))
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
            child: TextButton(
                onPressed: () async => await context
                    .push('/study/learn?deckGroupId=${deckGroup.id}'),
                child: Text(context.l10n.cardsToReview(count))),
          );
        });
  }
}

class EditableText extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;
  final TextStyle? style;

  const EditableText(
      {super.key, required this.text, required this.onTextChanged, this.style});

  @override
  State<EditableText> createState() => _EditableTextState();
}

class _EditableTextState extends State<EditableText> {
  final controller = TextEditingController();
  bool editing = false;

  @override
  void initState() {
    super.initState();
    controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: TextField(
                readOnly: !editing,
                decoration: InputDecoration(border: InputBorder.none),
                controller: controller,
                style: widget.style,
                onTap: () {
                  setState(() {
                    editing = true;
                  });
                },
                onTapOutside: (_) {
                  widget.onTextChanged(controller.text);
                  setState(() {
                    editing = false;
                  });
                },
                onSubmitted: (value) {
                  widget.onTextChanged(value);
                  setState(() {
                    editing = false;
                  });
                }),
          ),
          if (editing)
            IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  widget.onTextChanged(controller.text);
                  setState(() {
                    editing = false;
                  });
                })
        ],
      ),
    );
  }
}