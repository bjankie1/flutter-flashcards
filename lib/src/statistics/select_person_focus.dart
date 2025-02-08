import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/avatar.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/widgets.dart';

class SelectPersonFocus extends StatelessWidget {
  final void Function(String?) onUserChange; // Callback type defined here
  final String? userId;

  SelectPersonFocus({required this.userId, required this.onUserChange});

  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
        fetcher: (repository) => repository.listOwnStatsGrants(),
        builder: (context, users, _) {
          return Visibility(
            visible: users.isNotEmpty,
            child: ConstrainedBox(
              key: Key('stat_person_choice_container'),
              constraints: BoxConstraints(maxWidth: 400, minWidth: 200),
              child: InputDecorator(
                decoration: InputDecoration(
                    labelText: context.l10n.personFilterLabel,
                    border: InputBorder.none),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    value: userId,
                    items: [
                      DropdownMenuItem(
                          value: context.appState.userProfile.value!.id,
                          child: SizedBox(
                            width: 200,
                            child: ListTile(
                                dense: true,
                                leading: Avatar(
                                  size: 25,
                                ),
                                title: Text(
                                    context.appState.userProfile.value!.name)),
                          )),
                      ...users.map((user) {
                        final String name = (user.name.isEmpty) == true
                            ? user.email
                            : user.name;
                        return DropdownMenuItem(
                            value: user.id,
                            child: SizedBox(
                              width: 200,
                              child: ListTile(
                                  dense: true,
                                  leading: Avatar(size: 25, userId: user.id),
                                  title: Text(name)),
                            ));
                      })
                    ],
                    onChanged: (String? value) {
                      onUserChange(value);
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}