import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, GoogleAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/app_state.dart';
import 'package:provider/provider.dart';

import 'authentication.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;

  final String title;

  final FloatingActionButton? floatingActionButton;

  const BaseLayout(
      {required this.child,
      required this.title,
      this.floatingActionButton,
      super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                children: [
                  Text(appState.title),
                  Spacer(),
                  Consumer<AppState>(
                    builder: (context, appState, _) => AuthFunc(
                        loggedIn: appState.loggedIn,
                        signOut: () {
                          FirebaseAuth.instance.signOut();
                        }),
                  ),
                ],
              );
            },
          ),
        ),
        body: Center(
          child: child,
        ),
        floatingActionButton: floatingActionButton,
      );
    });
  }
}
