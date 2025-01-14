import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/snackbar_messaging.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

class InviteCollaboratorInput extends StatelessWidget {
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
                label: Text('email'),
                border: OutlineInputBorder(),
                helperText: 'Invitees email'),
            controller: _controller,
            validator: (value) => EmailValidator.validate(value!)
                ? null
                : 'Please enter a valid email',
          ),
        ),
        IconButton(
            tooltip: 'cancel',
            onPressed: () {
              context.cardRepository
                  .saveCollaborationInvitation(_controller.text);
            },
            icon: Icon(Icons.cancel)),
        IconButton(
            tooltip: 'Send invitation',
            onPressed: () async {
              await context.cardRepository
                  .saveCollaborationInvitation(_controller.text);
              context.showInfoSnackbar('Invitation sent');
            },
            icon: Icon(Icons.send))
      ],
    );
  }
}
