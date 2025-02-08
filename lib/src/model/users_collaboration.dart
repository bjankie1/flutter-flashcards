import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/dates.dart';
import 'package:flutter_flashcards/src/model/cards.dart';

typedef UserId = String;

class UserProfile extends FirebaseSerializable {
  final UserId id;
  final String name;
  final String email;
  final ThemeMode theme;
  final Locale locale;
  final DateTime? avatarUploadTime;

  UserProfile(
      {required this.id,
      required this.email,
      required this.name,
      required this.theme,
      required this.locale,
      this.avatarUploadTime});

  UserProfile copyWith(
      {String? email,
      String? name,
      ThemeMode? theme,
      Locale? locale,
      DateTime? avatarUploadTime}) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      avatarUploadTime: avatarUploadTime ?? this.avatarUploadTime,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'themeIndex': theme.index,
        'locale': locale.languageCode,
        'avatarUploadTime': avatarUploadTime,
      };

  factory UserProfile.fromJson(String id, Map<String, dynamic> data) =>
      UserProfile(
          id: id,
          email: data['email'] ?? '',
          name: data['name'],
          theme: ThemeMode.values[data['themeIndex']],
          locale: Locale(data['locale']),
          avatarUploadTime: (data['avatarUploadTime'] as Timestamp?)?.toDate());

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
          email == other.email &&
          name == other.name &&
          theme == other.theme &&
          locale == other.locale &&
          avatarUploadTime == other.avatarUploadTime;
}

/// The object will serve both purpose of initiating the collaboration
/// as well as identifying active collaborators.
/// Collaboration is bi-directional and it doesn't matter which user initiated
/// it.
enum InvitationStatus { pending, accepted, rejected }

class CollaborationInvitation implements FirebaseSerializable {
  String id;
  String initiatorUserId;
  String? receivingUserId;
  String receivingUserEmail;
  Timestamp sentTimestamp;
  Timestamp? lastChangeTimestamp;
  InvitationStatus status;

  CollaborationInvitation(
      {required this.id,
      required this.initiatorUserId,
      this.receivingUserId,
      required this.receivingUserEmail,
      required this.sentTimestamp,
      this.lastChangeTimestamp,
      required this.status});

  /// Method invoked by receiver of the invitation who can accept or reject the invitation
  CollaborationInvitation changeStatus(
          InvitationStatus status, String userId) =>
      CollaborationInvitation(
          id: id,
          initiatorUserId: initiatorUserId,
          receivingUserId: userId,
          receivingUserEmail: receivingUserEmail,
          sentTimestamp: sentTimestamp,
          lastChangeTimestamp: currentClockTimestamp,
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
        'receivingUserEmail': receivingUserEmail,
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
          receivingUserEmail: data['receivingUserEmail'],
          sentTimestamp: data['sentTimestamp'],
          lastChangeTimestamp: data['lastChangeTimestamp'],
          status: InvitationStatus.values
              .firstWhere((s) => s.name == data['status']));

  @override
  String? get idValue => id;
}