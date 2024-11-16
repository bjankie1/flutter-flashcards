import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'firebase_repository.dart';
import 'repository.dart';

class CardsRepositoryProvider extends FutureProvider<CardsRepository> {
  CardsRepositoryProvider({super.key})
      : super(
          create: (context) async {
            final logger = Logger();
            if (const bool.fromEnvironment("testing")) {
              logger.i('Instantiating in-memory repository');
              return InMemoryCardsRepository();
            } else {
              logger.i('Instantiating Firebase repository');
              return FirebaseCardsRepository();
            }
          },
          initialData: InMemoryCardsRepository(),
        );

  static CardsRepository of(BuildContext context, {bool listen = true}) {
    return Provider.of<CardsRepository>(context, listen: listen);
  }
}
