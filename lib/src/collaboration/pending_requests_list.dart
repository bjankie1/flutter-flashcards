import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class PendingRequestsList extends StatelessWidget {
  const PendingRequestsList({this.sent = false});

  final bool sent;

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository
            .pendingInvitations(sent: sent)
            .then((value) => value.toList()),
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
