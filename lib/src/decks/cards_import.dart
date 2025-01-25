import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';

class CardsImportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: context.l10n.cards,
      currentPage: PageIndex.cards,
      child: CardsImportWidget(),
    );
  }
}

class CardsImportWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
