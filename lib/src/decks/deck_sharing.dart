import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/model/repository.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:logger/logger.dart';

import '../common/avatar.dart';
import '../model/cards.dart' as model;

class DeckSharing extends StatefulWidget {
  final model.Deck deck;

  DeckSharing({super.key, required this.deck});

  @override
  State<DeckSharing> createState() => _DeckSharingState();
}

class _DeckSharingState extends State<DeckSharing> {
  final _log = Logger();

  final shareWithController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            context.l10n.deckSharingHeader,
            style: context.textTheme.titleLarge,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
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
                ),
              ),
              IconButton(
                  onPressed: () async => await _shareDeck(context),
                  icon: const Icon(Icons.person_add_alt_rounded)),
            ],
          ),
          Divider(),
          DeckGrants(
            deck: widget.deck,
            onRevokeGrant: () => setState(() {}),
          )
        ],
      ),
    );
  }

  Future<void> _shareDeck(BuildContext context) async {
    {
      await context.cardRepository
          .grantAccessToDeck(widget.deck.id!, shareWithController.text)
          .then(
              (value) =>
                  context.showInfoSnackbar(context.l10n.deckSharedMessage),
              onError: (e, stackTrace) {
        _log.e('Error sharing deck', error: e, stackTrace: stackTrace);
        context
            .showErrorSnackbar('${context.l10n.deckSharedFailedMessage}: $e');
      });
      shareWithController.clear();
      setState(() {});
    }
  }
}

class DeckGrants extends StatelessWidget {
  final model.Deck deck;
  final VoidCallback onRevokeGrant;

  const DeckGrants(
      {super.key, required this.deck, required this.onRevokeGrant});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.listGrantedDeckAccess(deck.id!),
        errorWidgetBuilder: (error) => Text(
              error.toString(),
              style: TextStyle(color: Colors.red),
            ),
        builder: (context, data, _) {
          return data.isEmpty
              ? Text(context.l10n.deckNotSharedMessage)
              : Expanded(
                  child: ListView(
                    children: data
                        .map(
                          (grant) => ListTile(
                            title: Text(grant.name),
                            subtitle: Text(grant.email),
                            leading: Avatar(size: 20, userId: grant.id),
                            trailing: IconButton(
                                onPressed: () async =>
                                    await _removeShare(context, grant.email),
                                icon: Icon(Icons.delete)),
                          ),
                        )
                        .toList(),
                  ),
                );
        });
  }

  Future<void> _removeShare(BuildContext context, String email) async {
    await context.cardRepository.revokeAccessToDeck(deck.id!, email);
    onRevokeGrant();
  }
}