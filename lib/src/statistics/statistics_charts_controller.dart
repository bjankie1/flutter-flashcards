import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../model/cards.dart' as model;
import '../decks/deck_list/decks_controller.dart';

part 'statistics_charts_controller.g.dart';

/// Data class representing the statistics charts state
class StatisticsChartsData {
  final Iterable<model.CardAnswer> answers;
  final bool isLoading;
  final String? errorMessage;

  const StatisticsChartsData({
    required this.answers,
    this.isLoading = false,
    this.errorMessage,
  });

  StatisticsChartsData copyWith({
    Iterable<model.CardAnswer>? answers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StatisticsChartsData(
      answers: answers ?? this.answers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Parameters for loading statistics data
class StatisticsLoadParams {
  final DateTime startDate;
  final DateTime endDate;
  final String? uid;

  const StatisticsLoadParams({
    required this.startDate,
    required this.endDate,
    this.uid,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StatisticsLoadParams &&
            runtimeType == other.runtimeType &&
            startDate == other.startDate &&
            endDate == other.endDate &&
            uid == other.uid;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate, uid);
}

/// Controller for managing statistics charts operations
@riverpod
class StatisticsChartsController extends _$StatisticsChartsController {
  final _log = Logger();

  @override
  Future<Iterable<model.CardAnswer>> build(StatisticsLoadParams params) async {
    _log.d(
      'Loading statistics data for date range: ${params.startDate} to ${params.endDate}, uid: ${params.uid}',
    );

    final repository = ref.read(cardsRepositoryProvider);
    return await repository.loadAnswers(
      params.startDate,
      params.endDate,
      uid: params.uid,
    );
  }
}
