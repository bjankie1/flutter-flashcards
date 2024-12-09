import 'package:flutter/material.dart';

import 'cards.dart' as model;
import 'repository.dart';

class CardProvider extends ChangeNotifier {
  final CardsRepository _repository;

  CardProvider(this._repository);

  void handleEvent(SaveCardEvent event) async {
    await _repository.saveCard(event.card);
    notifyListeners(); // Trigger UI update
  }
}

class SaveCardEvent {
  final model.Card card;

  SaveCardEvent(this.card);
}
