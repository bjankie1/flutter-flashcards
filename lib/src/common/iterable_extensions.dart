extension IterableExtensions<E> on Iterable<E> {
  Iterable<Iterable<E>> splitIterable(int batchSize) {
    final result = <Iterable<E>>[];
    final iterator = this.iterator;
    final batch = <E>[];
    while (iterator.moveNext()) {
      batch.add(iterator.current);
      if (batch.length == batchSize) {
        result.add([...batch]);
        batch.clear();
      }
    }
    if (batch.isNotEmpty) result.add([...batch]);
    return result;
  }
}
