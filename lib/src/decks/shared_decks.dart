import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/avatar.dart';
import 'package:flutter_flashcards/src/common/custom_theme.dart';
import 'package:flutter_flashcards/src/model/users_collaboration.dart';

import '../common/build_context_extensions.dart';
import '../model/cards.dart' as model;
import '../widgets.dart';

class SharedDeckListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader<Map<UserId, Iterable<model.Deck>>>(
      fetcher: (repository) => repository.listSharedDecks(),
      builder: (context, userToDecks, repository) {
        if (userToDecks.isEmpty) {
          return Center(child: Text(context.l10n.noSharedDecksMessage));
        }
        final avatars = _avatarsWidgets(userToDecks.keys);
        final List<(UserId, model.Deck)> userDeckTuple = userToDecks.entries
            .fold(
                [],
                (acc, entry) =>
                    [...acc, ...entry.value.map((deck) => (entry.key, deck))]);
        userDeckTuple.sort((t1, t2) => t1.$2.name.compareTo(t2.$2.name));
        return SizedBox(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userDeckTuple.isEmpty ? 1 : userDeckTuple.length,
              itemBuilder: (context, index) {
                if (userDeckTuple.isEmpty) {
                  return Center(child: Text(context.l10n.noCardsMessage));
                }
                final tuple = userDeckTuple[index];
                return SharedDeckItem(
                    avatar: avatars[tuple.$1]!, deck: tuple.$2);
              },
            ),
          ),
        );
      },
    );
  }

  Map<UserId, Widget> _avatarsWidgets(Iterable<UserId> userIds) {
    return Map.fromEntries(userIds.map((uid) => MapEntry(
        uid,
        Avatar(
          size: 20,
          userId: uid,
        ))));
  }
}

class SharedDeckItem extends StatelessWidget {
  final model.Deck deck;

  final Widget avatar;

  const SharedDeckItem({super.key, required this.deck, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // dense: true,
      title: Text(
        deck.name,
        style: context.textTheme.headlineMedium,
      ),
      subtitle: Text(deck.description ?? ''),
      leading: avatar,
      trailing: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.push_pin),
        label: Text('Select deck'),
      ),
    );
  }
}