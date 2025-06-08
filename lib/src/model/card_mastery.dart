enum CardMastery {
  /// Cards that haven't been reviewed yet
  new_,

  /// Cards that are actively being memorized (in learning or relearning state)
  learning,

  /// Cards in review state with relatively short intervals (< 21 days)
  young,

  /// Cards in review state with long intervals (>= 21 days)
  mature,
}
