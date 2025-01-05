// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app.dart';
import 'package:go_router/go_router.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    super.key,
    required this.loggedIn,
    required this.signOut,
  });

  final bool loggedIn;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 24, bottom: 8),
          child: FilledButton.icon(
              onPressed: () async {
                !loggedIn ? await context.push('/sign-in') : signOut();
              },
              icon: Icon(Icons.exit_to_app),
              label: !loggedIn
                  ? Text(context.l10n.signIn)
                  : Text(context.l10n.signOut)),
        ),
      ],
    );
  }
}
