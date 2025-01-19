import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class SelectPersonFocus extends StatelessWidget {
  final void Function(String?) onUserChange; // Callback type defined here

  final ValueNotifier<String?> selectedUser =
      ValueNotifier(null); //  selected user ID

  SelectPersonFocus({required this.onUserChange});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.listOwnStatsGrants(),
        builder: (context, users, _) {
          return ValueListenableBuilder(
            valueListenable: selectedUser,
            builder: (context, selected, _) => Visibility(
              visible: users.isNotEmpty,
              child: ConstrainedBox(
                key: Key('stat_person_choice_container'),
                constraints: BoxConstraints(maxWidth: 400, minWidth: 200),
                child: DropdownButton<String>(
                  value: selected,
                  items: [
                    DropdownMenuItem(
                        value: context.appState.userProfile?.id,
                        child: Text(context.appState.userProfile?.name ??
                            'not logged')),
                    ...users.map((user) {
                      final String name =
                          (user.name.isEmpty) == true ? user.email : user.name;
                      return DropdownMenuItem(
                          value: user.id, child: Text(name));
                    })
                  ],
                  onChanged: (String? value) {
                    onUserChange(value);
                  },
                ),
              ),
            ),
          );
        });
  }
}
