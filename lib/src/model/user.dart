import 'package:flutter/material.dart';

class UserProfile {
  final String id;

  final String name;

  final ThemeMode theme;

  final Locale locale;

  final String photoUrl;

  UserProfile(
      {required this.id,
      required this.name,
      required this.theme,
      required this.locale,
      required this.photoUrl});

  UserProfile copyWith(
      {String? name, ThemeMode? theme, Locale? locale, String? photoUrl}) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
