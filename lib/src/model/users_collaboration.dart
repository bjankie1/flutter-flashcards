import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/cards.dart';

class UserProfile extends FirebaseSerializable {
  final String id;
  final String name;
  final String email;
  final ThemeMode theme;
  final Locale locale;
  final String photoUrl;

  UserProfile(
      {required this.id,
      required this.email,
      required this.name,
      required this.theme,
      required this.locale,
      required this.photoUrl});

  UserProfile copyWith(
      {String? email,
      String? name,
      ThemeMode? theme,
      Locale? locale,
      String? photoUrl}) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'themeIndex': theme.index,
        'locale': locale.languageCode,
        'photoUrl': photoUrl,
      };

  factory UserProfile.fromJson(String id, Map<String, dynamic> data) =>
      UserProfile(
          id: id,
          email: data['email'] ?? '',
          name: data['name'],
          theme: ThemeMode.values[data['themeIndex']],
          locale: Locale(data['locale']),
          photoUrl: data['photoUrl']);

  @override
  String? get idValue => id;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;
}

/// The object will serve both purpose of initiating the collaboration
/// as well as identifying active collaborators.
/// Collaboration is bi-directional and it doesn't matter which user initiated
/// it.
enum InvitationStatus { pending, accepted, rejected }

class CollaborationInvitation implements FirebaseSerializable {
  String id;
  String initiatorUserId;
  String receivingUserId;
  Timestamp sentTimestamp;
  Timestamp? lastChangeTimestamp;
  InvitationStatus status;

  CollaborationInvitation(
      {required this.id,
      required this.initiatorUserId,
      required this.receivingUserId,
      required this.sentTimestamp,
      this.lastChangeTimestamp,
      required this.status});

  CollaborationInvitation changeStatus(InvitationStatus status) =>
      CollaborationInvitation(
          id: id,
          initiatorUserId: initiatorUserId,
          receivingUserId: receivingUserId,
          sentTimestamp: sentTimestamp,
          lastChangeTimestamp: Timestamp.now(),
          status: status);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CollaborationInvitation &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  Map<String, dynamic> toJson() => {
        'initiatorUserId': initiatorUserId,
        'receivingUserId': receivingUserId,
        'sentTimestamp': sentTimestamp,
        'lastChangeTimestamp': lastChangeTimestamp,
        'status': status.name
      };

  factory CollaborationInvitation.fromJson(
          String id, Map<String, dynamic> data) =>
      CollaborationInvitation(
          id: id,
          initiatorUserId: data['initiatorUserId'],
          receivingUserId: data['receivingUserId'],
          sentTimestamp: data['sentTimestamp'],
          lastChangeTimestamp: data['lastChangeTimestamp'],
          status: InvitationStatus.values
              .firstWhere((s) => s.name == data['status']));

  @override
  String? get idValue => id;
}
