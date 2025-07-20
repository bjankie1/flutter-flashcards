import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/users_collaboration.dart';
import 'collaboration_controller.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';

class CollaboratorsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collaborationAsync = ref.watch(collaborationControllerProvider);

    return collaborationAsync.when(
      data: (data) => _buildList(context, data.collaborators),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(context.l10n.errorLoadingCollaborators(error.toString())),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(collaborationControllerProvider.notifier).refresh();
              },
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<UserProfile> collaborators) {
    if (collaborators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              context.l10n.noCollaboratorsYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.inviteCollaboratorHint,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          final collaborator = collaborators[index];
          return ListTile(
            title: Text(collaborator.name),
            leading: Icon(Icons.person),
            subtitle: Text(collaborator.email),
          );
        },
        itemCount: collaborators.length,
      ),
    );
  }
}
