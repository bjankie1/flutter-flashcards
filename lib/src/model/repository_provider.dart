import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:provider/provider.dart';

import 'repository.dart';

class CardsRepositoryProvider extends ListenableProvider<CardsRepository> {
  CardsRepositoryProvider(CardsRepository repository)
      : super(create: (context) => repository);

  static CardsRepository of(BuildContext context, {bool listen = true}) {
    return Provider.of<CardsRepository>(context, listen: listen);
  }
}
