import 'package:flutter_flashcards/src/common/iterable_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iterable should be split into chunks', () async {
    final iterable = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final chunks = iterable.splitIterable(3);
    expect(chunks.length, 4);
    expect(chunks.first, [1, 2, 3]);
    expect(chunks.last, [10]);
  });
  test('empty iterable should generate empty batches', () async {
    final iterable = <int>[];
    final chunks = iterable.splitIterable(3);
    expect(chunks.length, 0);
  });
  test('no empty chunk should be added at the end', () async {
    final iterable = [1, 2, 3, 4, 5, 6];
    final chunks = iterable.splitIterable(3);
    expect(chunks.length, 2);
  });
}
