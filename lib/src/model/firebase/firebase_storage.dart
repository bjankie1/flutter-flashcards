import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  var _log = Logger();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _cardIllustrationStoragePath(String cardId, String name) {
    return '/users/$_userId/cardImages/$cardId/$name';
  }

  String _userAvatarStoragePath({String? userId}) {
    return '/users/${userId ?? _userId}/avatar';
  }

  Future<void> uploadCardIllustration(
    XFile image,
    String cardId,
    String name, {
    void Function()? onPaused,
    void Function()? onCancelled,
    void Function()? onError,
    void Function()? onSuccess,
  }) async {
    if (_userId == null) throw Exception('User not logged');
    _log.i(
      'Uploading image ${image.name} from ${image.path} as ${image.mimeType}',
    );
    final storageRef = _storage.ref();
    final fileRef = storageRef.child(
      _cardIllustrationStoragePath(cardId, name),
    );
    await _uploadDataToStorage(
      image,
      fileRef,
      onPaused: onPaused,
      onCancelled: onCancelled,
      onError: onError,
      onSuccess: onSuccess,
    );
  }

  Future<void> uploadUserAvatar(
    XFile image, {
    void Function()? onPaused,
    void Function()? onCancelled,
    void Function()? onError,
    void Function()? onSuccess,
  }) async {
    if (_userId == null) throw Exception('User not logged');
    _log.i(
      'Uploading user avatar ${image.name} from ${image.path} as ${image.mimeType}',
    );
    final storageRef = _storage.ref();
    final fileRef = storageRef.child(_userAvatarStoragePath());
    await _uploadDataToStorage(
      image,
      fileRef,
      onPaused: onPaused,
      onCancelled: onCancelled,
      onError: onError,
      onSuccess: onSuccess,
    );
  }

  Future<void> _uploadDataToStorage(
    XFile image,
    Reference fileRef, {
    void Function()? onPaused,
    void Function()? onCancelled,
    void Function()? onError,
    void Function()? onSuccess,
  }) async {
    final bytes = await image.readAsBytes();
    final task = fileRef.putData(
      bytes,
      SettableMetadata(contentType: image.mimeType),
    );
    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
        case TaskState.paused:
          if (onPaused != null) onPaused();
        case TaskState.canceled:
          if (onCancelled != null) onCancelled();
        case TaskState.error:
          if (onError != null) onError();
        case TaskState.success:
          if (onSuccess != null) onSuccess();
      }
    });
  }

  Future<String> cardIllustrationUrl(String cardId, String name) async {
    final storageRef = _storage.ref();
    final fileRef = storageRef.child(
      _cardIllustrationStoragePath(cardId, name),
    );
    String url = await fileRef.getDownloadURL();
    return url;
  }

  Future<String?> userAvatarUrl({String? userId}) async {
    final storageRef = _storage.ref();
    final fileRef = storageRef.child(_userAvatarStoragePath(userId: userId));
    try {
      return await fileRef.getDownloadURL();
    } on FirebaseException catch (error, stackTrace) {
      _log.w(
        'Error getting user avatar URL: $error with code ${error.code}',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<(Uint8List?, FullMetadata)> cardIllustrationData(
    String cardId,
    String name,
  ) async {
    final storageRef = _storage.ref();
    final fileRef = storageRef.child(
      _cardIllustrationStoragePath(cardId, name),
    );
    final metadata = await fileRef.getMetadata();
    final data = await fileRef.getData();
    return (data, metadata);
  }

  Image getImageFromPath(XFile pickedFile) {
    final Image image;

    if (kIsWeb) {
      image = Image.network(pickedFile.path);
    } else {
      image = Image.file(File(pickedFile.path));
    }

    return image;
  }

  /// Demonstrates creating an Image widget from an XFile's bytes.
  Future<Image> getImageFromBytes(XFile pickedFile) async {
    final Image image;

    image = Image.memory(await pickedFile.readAsBytes());

    return image;
  }
}
