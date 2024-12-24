import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'firebase/firebase_repository.dart';
import 'repository.dart';

class CardsRepositoryProvider extends ListenableProvider<CardsRepository> {
  CardsRepositoryProvider({super.key})
      : super(
          create: (context) {
            final logger = Logger();
            if (const bool.fromEnvironment("testing")) {
              logger.i('Instantiating in-memory repository');
              return InMemoryCardsRepository();
            } else {
              logger.i('Instantiating Firebase repository');
              return FirebaseCardsRepository();
            }
          },
        );

  static CardsRepository of(BuildContext context, {bool listen = true}) {
    return Provider.of<CardsRepository>(context, listen: listen);
  }
}
