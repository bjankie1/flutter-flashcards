import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/reviews/cards_review_widget.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import '../layout/base_layout.dart';

class StudyCardsPage extends StatefulWidget {
  // Optional filter for deckId
  final String? deckId;

  const StudyCardsPage({this.deckId});

  @override
  State<StatefulWidget> createState() => _StudyCardsPageState();
}

class _StudyCardsPageState extends State<StudyCardsPage> {
  ValueNotifier<int> _currentCardIndex = ValueNotifier<int>(0);
  ValueListenable<int> get currentCardIndex => _currentCardIndex;

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) =>
          repository.loadCardToReview(deckId: widget.deckId),
      builder: (context, cards, repository) {
        if (cards.isEmpty) {
          return BaseLayout(
            title: context.l10n.noCardsToLearn,
            currentPage: PageIndex.learning,
            child: Text(context.l10n.noCardsToLearn),
          );
        }

        return ValueListenableBuilder(
          valueListenable: currentCardIndex,
          builder: (context, cardIndex, _) => BaseLayout(
              title: context.l10n.learnProgressMessage(cardIndex, cards.length),
              currentPage: PageIndex.learning,
              child: CardsReview(
                  cards: cards,
                  currentCardIndex: currentCardIndex,
                  onNextCard: (newIndex) {
                    _currentCardIndex.value = newIndex;
                  })),
        );
      },
    );
  }
}
