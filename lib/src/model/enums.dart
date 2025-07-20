enum ImagePlacement { question, explanation }

enum State {
  newState(0),
  learning(1),
  review(2),
  relearning(3);

  const State(this.val);

  final int val;

  factory State.fromName(String name) =>
      State.values.firstWhere((element) => element.name == name);
}

enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const Rating(this.val);

  final int val;
}

enum DeckCategory {
  language,
  history,
  science,
  biology,
  geography,
  math,
  other;

  factory DeckCategory.fromName(String name) =>
      DeckCategory.values.firstWhere((element) => element.name == name);
}

enum CardReviewVariant {
  front,
  back;

  factory CardReviewVariant.fromString(String name) {
    switch (name) {
      case 'front':
        return CardReviewVariant.front;
      case 'back':
        return CardReviewVariant.back;
      default:
        return CardReviewVariant.front;
    }
  }
}
