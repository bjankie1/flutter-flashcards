import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/base_layout.dart';
import 'package:flutter_flashcards/src/widgets.dart';
import 'package:provider/provider.dart';

class StudyStatisticsPage extends StatefulWidget {
  @override
  State<StudyStatisticsPage> createState() => _StudyStatisticsPageState();
}

class _StudyStatisticsPageState extends State<StudyStatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: 'Statistics',
        currentPage: PageIndex.statistics,
        child: ChangeNotifierProvider(
          create: (context) => FiltersModel(),
          child: Column(
            children: [StatisticsFilter(), Expanded(child: StatisticsCharts())],
          ),
        ));
  }
}

class StatisticsCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FiltersModel>(
      builder: (BuildContext context, FiltersModel value, Widget? child) {
        return RepositoryLoader(
            fetcher: (repository) => repository.loadAnswers(
                value.selectedDates.start, value.selectedDates.end),
            builder: (context, result, _) {
              return Column(
                children: [
                  Text('Answers: ${result.length}'),
                ],
              );
            });
      },
    );
  }
}

class FiltersModel extends ChangeNotifier {
  DateTimeRange _selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  DateTimeRange get selectedDates => _selectedDates;

  set selectedDates(DateTimeRange value) {
    _selectedDates = value;
    notifyListeners();
  }
}

class StatisticsFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FiltersModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max, // Expands the Row to fill the width
          mainAxisAlignment:
              MainAxisAlignment.center, // Centers children horizontally
          spacing: 8.0,
          children: [
            SizedBox(
              width: 150,
              child: InputDatePickerFormField(
                  initialDate: model.selectedDates.start,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now()),
            ),
            SizedBox(
              width: 150,
              child: InputDatePickerFormField(
                  initialDate: model.selectedDates.end,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now()),
            ),
            IconButton(
              onPressed: () async {
                DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now());
                if (range != null) {
                  model.selectedDates = range;
                }
              },
              icon: Icon(Icons.calendar_month),
            )
          ],
        ),
      );
    });
  }
}
