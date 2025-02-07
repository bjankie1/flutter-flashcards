import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/assets.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:flutter_flashcards/src/model/repository.dart';

class UserAvatar extends StatelessWidget {
  final double size;

  /// Alternative userId to show avatars of other users
  final String? userId;

  UserAvatar({this.size = 50, this.userId});

  Future<void> loadAvatarUrl(BuildContext context) async {
    if (userId != null) {
      final url = await context.storageService.userAvatarUrl(userId: userId);
      if (url != null) {
        _avatarImage.value = NetworkImage(url);
      }
    } else if (context.appState.userAvatarUrl.value != null) {
      _avatarImage.value = NetworkImage(context.appState.userAvatarUrl.value!);
      context.appState.userAvatarUrl.addListener(() {
        if (context.appState.userAvatarUrl.value != null) {
          _avatarImage.value =
              NetworkImage(context.appState.userAvatarUrl.value!);
        }
      });
    }
  }

  final ValueNotifier<ImageProvider?> _avatarImage =
      ValueNotifier<ImageProvider?>(randomFace);

  @override
  Widget build(BuildContext context) {
    loadAvatarUrl(context);
    return SizedBox(
        height: size,
        width: size,
        child: ValueListenableBuilder(
          valueListenable: _avatarImage,
          builder: (context, image, _) => CircleAvatar(
            minRadius: size / 2,
            backgroundImage: image ?? randomFace,
          ),
        ));
  }
}