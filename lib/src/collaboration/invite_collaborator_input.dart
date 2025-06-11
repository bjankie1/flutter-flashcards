import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

class InviteCollaboratorInput extends StatefulWidget {
  @override
  State<InviteCollaboratorInput> createState() =>
      _InviteCollaboratorInputState();
}

class _InviteCollaboratorInputState extends State<InviteCollaboratorInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            ),
            controller: _controller,
            validator: (value) => EmailValidator.validate(value!)
                ? null
                : context.l10n.invalidEmailMessage,
          ),
        ),
        IconButton(
          tooltip: 'cancel',
          onPressed: () {
            _controller.clear();
          },
          icon: Icon(Icons.cancel),
        ),
        IconButton(
          tooltip: context.l10n.sendInvitationButtonTooltip,
          onPressed: () async {
            await context.cardRepository
                .grantStatsAccess(_controller.text)
                .then(
                  (_) async {
                    if (!mounted) return;
                    _controller.clear();
                    context.showInfoSnackbar(
                      context.l10n.invitationSentMessage,
                    );
                  },
                  onError: (e) {
                    if (!mounted) return;
                    context.showErrorSnackbar(e.toString());
                  },
                );
          },
          icon: Icon(Icons.send),
        ),
      ],
    );
  }
}
