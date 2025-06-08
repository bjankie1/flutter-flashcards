import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';
import 'package:flutter_flashcards/src/model/study_session.dart';
import 'package:flutter_flashcards/src/reviews/cards_review_widget.dart';
import 'package:flutter_flashcards/src/widgets.dart';

import '../layout/base_layout.dart';

class StudyCardsPage extends StatelessWidget {
  // Optional filter for deckId
  final String? deckId;
  final String? deckGroupId;

  const StudyCardsPage({this.deckId, this.deckGroupId});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) async {
        final session = StudySession(
          repository: repository,
          deckId: deckId,
          deckGroupId: deckGroupId,
        );
        await session.startStudySession().logError('Error starting session');
        return session;
      },
      builder: (context, session, repository) {
        if (session.remainingCards == 0) {
          return BaseLayout(
            title: Text(context.l10n.noCardsToLearn),
            currentPage: PageIndex.cards,
            child: Text(context.l10n.noCardsToLearn),
          );
        }

        return BaseLayout(
          title: ListenableBuilder(
            listenable: session,
            builder: (context, _) {
              return Text(
                context.l10n.learnProgressMessage(session.remainingCards),
              );
            },
          ),
          currentPage: PageIndex.cards,
          child: CardsReview(session: session),
        );
      },
    );
  }
}
