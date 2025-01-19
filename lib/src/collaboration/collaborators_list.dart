import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class CollaboratorsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) =>
            repository.listGivenStatsGrants().then((value) => value.toList()),
        builder: (context, collaborators, _) {
          return Expanded(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(collaborators[index].name),
                    leading: Icon(Icons.person),
                    subtitle: Text(collaborators[index].email),
                  );
                },
                itemCount: collaborators.length),
          );
        });
  }
}
