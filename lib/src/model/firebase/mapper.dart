import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/cards.dart' as model;
import 'package:flutter_flashcards/src/model/user.dart';

abstract class FirebaseSerializer<T> {
  Future<T> fromSnapshot(DocumentSnapshot snapshot);
  Future<void> toSnapshot(T value, DocumentReference docRef) async {
    await _updateUserId(docRef);
    await docRef.set(_serialize(value), SetOptions(merge: true));
  }

  Map<String, dynamic> _serialize(T value);

  _updateUserId(DocumentReference doc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await doc.set({'userId': user.uid}, SetOptions(merge: true));
    }
  }
}

class DeckSerializer extends FirebaseSerializer<model.Deck> {
  @override
  Future<model.Deck> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _deckFromJson(data, id: snapshot.id);
  }

  model.Deck _deckFromJson(Map<String, dynamic> json, {String? id}) =>
      model.Deck(
        id: id,
        name: json['name'] as String,
        description: json['description'] as String?,
        parentDeckId: json['parentDeckId'] as String?,
        deckOptions: json['deckOptions'] != null
            ? _deckOptionsFromJson(json['deckOptions'] as Map<String, dynamic>)
            : null,
      );

  @override
  Map<String, dynamic> _serialize(model.Deck value) => {
        'name': value.name,
        'description': value.description,
        'parentDeckId': value.parentDeckId,
        'deckOptions': value.deckOptions != null
            ? _deckOptionsToJson(value.deckOptions!)
            : null,
      };

  model.DeckOptions _deckOptionsFromJson(Map<String, dynamic> json) =>
      model.DeckOptions(
        cardsDaily: json['cardsDaily'] as int,
        newCardsDailyLimit: json['newCardsDailyLimit'] as int,
        maxInterval: Duration(
            milliseconds:
                json['maxInterval'] as int), // Parse from milliseconds
      );

  Map<String, dynamic> _deckOptionsToJson(model.DeckOptions deckOptions) => {
        'cardsDaily': deckOptions.cardsDaily,
        'newCardsDailyLimit': deckOptions.newCardsDailyLimit,
        'maxInterval':
            deckOptions.maxInterval.inMilliseconds, // Store as milliseconds
      };
}

class TagSerializer extends FirebaseSerializer<model.Tag> {
  @override
  Future<model.Tag> fromSnapshot(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return _tagFromJson(data);
  }

  @override
  Map<String, dynamic> _serialize(model.Tag tag) => {'name': tag.name};

  model.Tag _tagFromJson(Map<String, dynamic> json) =>
      model.Tag(name: json['name'] as String);
}

class UserSerializer extends FirebaseSerializer<UserProfile> {
  @override
  Map<String, dynamic> _serialize(UserProfile value) => {
        'name': value.name,
        'themeIndex': value.theme.index,
        'locale': value.locale.languageCode,
        'photoUrl': value.photoUrl,
      };

  @override
  Future<UserProfile> fromSnapshot(DocumentSnapshot<Object?> snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
        id: snapshot.id,
        name: data['name'],
        theme: ThemeMode.values[data['themeIndex']],
        locale: Locale(data['locale']),
        photoUrl: data['photoUrl']);
  }
}
