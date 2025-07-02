import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/themes.dart';
import 'package:flutter_flashcards/src/layout/base_layout.dart';
import 'package:flutter_flashcards/src/collaboration/collaborators_list.dart';
import 'package:flutter_flashcards/src/collaboration/invite_collaborator_input.dart';

class CollaborationPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseLayout(
      title: Text(context.l10n.collaboration),
      currentPage: PageIndex.collaboration,
      child: CollaboratorsWidget(),
    );
  }
}

class CollaboratorsWidget extends ConsumerWidget {
  const CollaboratorsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            color: ColorScheme.of(context).surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    context.l10n.collaboratorsHeader,
                    style: context.textTheme.headlineSmall,
                  ),
                  InviteCollaboratorInput(),
                  SizedBox(height: 20),
                  CollaboratorsList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
