import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/collaboration/collaborators_list.dart';
import 'package:flutter_flashcards/src/collaboration/invite_collaborator_input.dart';
import 'package:flutter_flashcards/src/collaboration/pending_requests_list.dart';

class CollaborationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: context.l10n.collaboration,
        currentPage: PageIndex.collaboration,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InviteCollaboratorInput(),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                context.l10n.collaboratorsHeader,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              CollaboratorsList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                context.l10n.pendingInvitationsHeader,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              PendingRequestsList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                context.l10n.sentInvitationsHeader,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              PendingRequestsList(sent: true),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
