import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../model/cards.dart' as model;
import '../model/repository.dart';
import '../widgets.dart';

class DeckListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader<Iterable<model.Deck>>(
      fetcher: (repository) => repository.loadDecks(),
      builder: (context, decksIterable, repository) {
        final decks = decksIterable.toList();
        decks.sort((deck1, deck2) => deck1.name.compareTo(deck2.name));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: decks.isEmpty ? 1 : decks.length,
            itemBuilder: (context, index) {
              if (decks.isEmpty) {
                return Center(child: Text(context.l10n.noCardsMessage));
              }
              final deck = decks[index];
              return DeckListItem(deck: deck);
            },
          ),
        );
      },
    );
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async {
    final repository = Provider.of<CardsRepository>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.l10n.deleteDeck(deck.name)),
              content: Text(context.l10n.deleteDeckConfirmation),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(context.ml10n.cancelButtonLabel),
                ),
                FilledButton(
                  onPressed: () async {
                    await repository.deleteDeck(deck.id!);
                    context.pop();
                  },
                  child: Text(context.l10n.delete),
                ),
              ],
            ));
  }

  void startLearning(BuildContext context, model.Deck deck) async {
    try {
      await context.push('/study/learn?deckId=${deck.id}');
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text('Error loading cards',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
            ],
          )));
    }
  }
}

class DeckListItem extends StatelessWidget {
  const DeckListItem({
    super.key,
    required this.deck,
  });

  final model.Deck deck;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () async {
        await context.push('/decks/${deck.id}');
      },
      title: Text(
        deck.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      subtitle: Row(
        children: [
          DeckCardsNumber(deck),
          DeckCardsToReview(deck),
          SizedBox(
            width: 20,
          ),
          DeckSharing(deck),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await deleteDeck(context, deck);
                  },
                ),
                FilledButton(
                  onPressed: () async => startLearning(context, deck),
                  child: Text(context.l10n.learn),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> deleteDeck(BuildContext context, model.Deck deck) async =>
      DeckListWidget().deleteDeck(context, deck);

  void startLearning(BuildContext context, model.Deck deck) =>
      DeckListWidget().startLearning(context, deck);
}

class DeckSharing extends StatefulWidget {
  final model.Deck deck;

  const DeckSharing(this.deck);

  @override
  State<DeckSharing> createState() => _DeckSharingState();
}

class _DeckSharingState extends State<DeckSharing> {
  final _log = Logger();

  bool isNewSharePressed = false;

  final shareWithController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people),
        if (!isNewSharePressed) DeckGrants(widget.deck),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: isNewSharePressed ? 200 : 0,
          child: isNewSharePressed
              ? TextFormField(
                  decoration: InputDecoration(
                      // label: Text(context.l10n.inviteCollaboratorPrompt),
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(20)),
                      helperText: context.l10n.invitationEmailHelperText),
                  controller: shareWithController,
                  validator: (value) => EmailValidator.validate(value!)
                      ? null
                      : context.l10n.invalidEmailMessage,
                )
              : SizedBox.shrink(),
        ),
        if (!isNewSharePressed)
          IconButton(
            onPressed: () {
              setState(() {
                isNewSharePressed = true;
              });
            },
            icon: const Icon(Icons.share),
            tooltip: context.l10n.add,
          ),
        if (isNewSharePressed)
          IconButton(
              onPressed: () {
                shareWithController.clear();
                setState(() {
                  isNewSharePressed = false;
                });
              },
              icon: Icon(Icons.cancel_outlined)),
        if (isNewSharePressed)
          IconButton(
              onPressed: () async {
                await context.cardRepository
                    .grantAccessToDeck(
                        widget.deck.id!, shareWithController.text)
                    .then(
                        (value) => context
                            .showInfoSnackbar(context.l10n.deckSharedMessage),
                        onError: (e, stackTrace) {
                  _log.e('Error sharing deck',
                      error: e, stackTrace: stackTrace);
                  context.showErrorSnackbar(
                      '${context.l10n.deckSharedFailedMessage}: $e');
                });
                shareWithController.clear();
                setState(() {
                  isNewSharePressed = false;
                });
              },
              icon: const Icon(Icons.check)),
      ],
    );
  }
}

class DeckGrants extends StatelessWidget {
  final model.Deck deck;

  const DeckGrants(this.deck);

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.listGrantedDeckAccess(deck.id!),
        builder: (context, data, _) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: data
                  .map((grant) => CircleAvatar(child: Text(grant.name[0])))
                  .toList(),
            ),
          );
        });
  }
}

class DeckCardsNumber extends RepositoryLoader<int> {
  DeckCardsNumber(model.Deck deck)
      : super(
            fetcher: (repository) => repository.getCardCount(deck.id!),
            builder: (context, data, _) {
              final cardCount = data;
              return TagText("${context.l10n.cards}: $cardCount");
            });
}

class DeckCardsToReview extends RepositoryLoader<Map<model.State, int>> {
  DeckCardsToReview(model.Deck deck)
      : super(
            fetcher: (repository) =>
                repository.cardsToReviewCount(deckId: deck.id!),
            builder: (context, data, _) {
              final cardCount = data.values.reduce((agg, next) => agg + next);
              return TagText(context.l10n.cardsToReview(cardCount));
            });
}

class TagText extends StatelessWidget {
  const TagText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest, // Use theme color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(text),
        ),
      ),
    );
  }
}