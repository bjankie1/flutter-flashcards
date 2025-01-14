import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/collaboration/invite_collaborator_input.dart';
import 'package:flutter_flashcards/src/widgets.dart';

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
              Text('Invite collaborator'),
              InviteCollaboratorInput(),
              SizedBox(
                height: 20,
              ),
              Text('Collaborators'),
              CollaboratorsList(),
              Text('Pending requests'),
              PendingRequestsList()
            ],
          ),
        ));
  }
}

class CollaboratorsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) =>
            repository.loadCollaborators().then((value) => value.toList()),
        builder: (context, collaborators, _) {
          return Expanded(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(collaborators[index]),
                  );
                },
                itemCount: collaborators.length),
          );
        });
  }
}

class PendingRequestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) =>
            repository.pendingInvitations().then((value) => value.toList()),
        builder: (context, invitations, _) {
          return Expanded(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(invitations[index].receivingUserEmail),
                        Text(invitations[index].status.name),
                      ],
                    ),
                  );
                },
                itemCount: invitations.length),
          );
        });
  }
}