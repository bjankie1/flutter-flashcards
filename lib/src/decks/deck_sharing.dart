import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:logger/logger.dart';

import '../common/avatar.dart';
import '../model/cards.dart' as model;

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
        if (!isNewSharePressed) const Icon(Icons.people),
        if (!isNewSharePressed) DeckGrants(widget.deck),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: isNewSharePressed ? 120 : 0,
          child: isNewSharePressed
              ? TextFormField(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.person),
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
                  .map((grant) => Tooltip(
                      message: grant.name.isEmpty ? grant.email : grant.name,
                      child: Avatar(size: 20, userId: grant.id)))
                  .toList(),
            ),
          );
        });
  }
}