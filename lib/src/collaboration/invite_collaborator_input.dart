import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

class InviteCollaboratorInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextFormField(
          decoration: InputDecoration(
              label: Text('email'),
              border: OutlineInputBorder(),
              helperText: 'Invitees email'),
          controller: _controller,
          validator: (value) => EmailValidator.validate(value!)
              ? null
              : 'Please enter a valid email',
        ),
        IconButton(
            tooltip: 'cancel',
            onPressed: () {
              context.cardRepository
                  .saveCollaborationInvitation(_controller.text);
            },
            icon: Icon(Icons.cancel)),
        IconButton(
            tooltip: 'send invitation',
            onPressed: () {
              context.cardRepository
                  .saveCollaborationInvitation(_controller.text);
            },
            icon: Icon(Icons.send))
      ],
    );
  }
}
