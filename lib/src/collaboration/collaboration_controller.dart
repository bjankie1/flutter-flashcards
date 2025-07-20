import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../model/users_collaboration.dart';
import '../decks/deck_list/decks_controller.dart';

part 'collaboration_controller.g.dart';

/// Data class representing the collaboration state
class CollaborationData {
  final List<UserProfile> collaborators;
  final String inviteEmail;
  final bool isInviting;
  final String? errorMessage;

  const CollaborationData({
    required this.collaborators,
    this.inviteEmail = '',
    this.isInviting = false,
    this.errorMessage,
  });

  CollaborationData copyWith({
    List<UserProfile>? collaborators,
    String? inviteEmail,
    bool? isInviting,
    String? errorMessage,
  }) {
    return CollaborationData(
      collaborators: collaborators ?? this.collaborators,
      inviteEmail: inviteEmail ?? this.inviteEmail,
      isInviting: isInviting ?? this.isInviting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing collaboration operations
@riverpod
class CollaborationController extends _$CollaborationController {
  final Logger _log = Logger();

  @override
  AsyncValue<CollaborationData> build() {
    _loadCollaborators();
    return const AsyncValue.loading();
  }

  /// Loads all collaborators from the repository
  Future<void> _loadCollaborators() async {
    try {
      _log.d('Loading collaborators');
      state = const AsyncValue.loading();
      final repository = ref.read(cardsRepositoryProvider);
      final collaborators = await repository.listGivenStatsGrants();
      final collaboratorsList = collaborators.toList();
      state = AsyncValue.data(
        CollaborationData(collaborators: collaboratorsList),
      );
      _log.d('Successfully loaded ${collaboratorsList.length} collaborators');
    } catch (error, stackTrace) {
      _log.e(
        'Error loading collaborators',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refreshes the collaborators data
  Future<void> refresh() async {
    await _loadCollaborators();
  }

  /// Updates the invite email
  void updateInviteEmail(String email) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(inviteEmail: email));
    }
  }

  /// Clears the invite email
  void clearInviteEmail() {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(inviteEmail: ''));
    }
  }

  /// Sends an invitation to collaborate
  Future<void> sendInvitation() async {
    final currentData = state.value;
    if (currentData == null || currentData.inviteEmail.isEmpty) return;

    try {
      _log.d('Sending invitation to: ${currentData.inviteEmail}');
      state = AsyncValue.data(
        currentData.copyWith(isInviting: true, errorMessage: null),
      );

      final repository = ref.read(cardsRepositoryProvider);
      await repository.grantStatsAccess(currentData.inviteEmail);

      // Refresh the collaborators list after successful invitation
      await _loadCollaborators();

      _log.d('Successfully sent invitation to: ${currentData.inviteEmail}');
    } catch (error, stackTrace) {
      _log.e('Error sending invitation', error: error, stackTrace: stackTrace);
      final updatedData = currentData.copyWith(
        isInviting: false,
        errorMessage: error.toString(),
      );
      state = AsyncValue.data(updatedData);
    }
  }

  /// Gets the current invite email
  String getInviteEmail() {
    return state.value?.inviteEmail ?? '';
  }

  /// Gets whether an invitation is currently being sent
  bool getIsInviting() {
    return state.value?.isInviting ?? false;
  }

  /// Gets the current error message
  String? getErrorMessage() {
    return state.value?.errorMessage;
  }

  /// Gets the list of collaborators
  List<UserProfile> getCollaborators() {
    return state.value?.collaborators ?? [];
  }
}
