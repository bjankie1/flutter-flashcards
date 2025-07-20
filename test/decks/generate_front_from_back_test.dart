import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flashcards/src/genkit/functions.dart';

void main() {
  group('GeneratedAnswer', () {
    test('should create GeneratedAnswer with answer and explanation', () {
      const answer = 'Test answer';
      const explanation = 'Test explanation';

      const generatedAnswer = GeneratedAnswer(answer, explanation);

      expect(generatedAnswer.answer, equals(answer));
      expect(generatedAnswer.explanation, equals(explanation));
    });

    test('should handle empty strings', () {
      const generatedAnswer = GeneratedAnswer('', '');

      expect(generatedAnswer.answer, equals(''));
      expect(generatedAnswer.explanation, equals(''));
    });
  });
}
