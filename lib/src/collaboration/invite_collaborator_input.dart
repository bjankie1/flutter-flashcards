import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'collaboration_controller.dart';

class InviteCollaboratorInput extends ConsumerStatefulWidget {
  @override
  ConsumerState<InviteCollaboratorInput> createState() =>
      _InviteCollaboratorInputState();
}

class _InviteCollaboratorInputState
    extends ConsumerState<InviteCollaboratorInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final controller = ref.read(collaborationControllerProvider.notifier);
    controller.updateInviteEmail(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final collaborationAsync = ref.watch(collaborationControllerProvider);

    return collaborationAsync.when(
      data: (data) => _buildInput(context, data),
      loading: () => _buildInput(context, null),
      error: (error, stackTrace) => _buildInput(context, null),
    );
  }

  Widget _buildInput(BuildContext context, CollaborationData? data) {
    final isInviting = data?.isInviting ?? false;
    final errorMessage = data?.errorMessage;

    // Show error message if there is one
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showErrorSnackbar(errorMessage);
      });
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300, minWidth: 300),
          child: TextFormField(
            decoration: InputDecoration(
              label: Text(context.l10n.inviteCollaboratorPrompt),
              border: OutlineInputBorder(),
              helperText: context.l10n.invitationEmailHelperText,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_outlined),
                      onPressed: () {
                        _controller.clear();
                        ref
                            .read(collaborationControllerProvider.notifier)
                            .clearInviteEmail();
                      },
                    )
                  : null,
            ),
            controller: _controller,
            validator: (value) => EmailValidator.validate(value!)
                ? null
                : context.l10n.invalidEmailMessage,
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: isInviting
              ? null
              : () async {
                  final controller = ref.read(
                    collaborationControllerProvider.notifier,
                  );
                  await controller.sendInvitation();

                  if (!mounted) return;

                  // Show success message if no error
                  final currentData = ref
                      .read(collaborationControllerProvider)
                      .value;
                  if (currentData?.errorMessage == null) {
                    _controller.clear();
                    context.showInfoSnackbar(
                      context.l10n.invitationSentMessage,
                    );
                  }
                },
          icon: isInviting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.send),
          label: Text(context.l10n.sendInvitationButtonTooltip),
        ),
      ],
    );
  }
}
