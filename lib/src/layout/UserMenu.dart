import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/UserAvatar.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:go_router/go_router.dart';

class UserMenu extends StatelessWidget {
  final Widget child;

  const UserMenu({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, 30),
      popUpAnimationStyle: AnimationStyle(
          curve: Easing.emphasizedDecelerate,
          duration: const Duration(seconds: 1)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
            child: ListTile(
          title: Text(context.appState.userProfile.value?.email ?? '-'),
          leading: UserAvatar(
            size: 20,
          ),
        )),
        PopupMenuItem<int>(
          child: ListTile(
              title: Text(context.l10n.settings),
              leading: Icon(Icons.settings_outlined)),
          onTap: () {
            context.goNamed('settings');
          },
        ),
        PopupMenuDivider(),
        PopupMenuItem<int>(
          child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(context.l10n.signOut)),
          onTap: () {
            FirebaseAuth.instance.signOut();
            context.go('/');
          },
        ),
      ],
      child: child,
    );
  }
}