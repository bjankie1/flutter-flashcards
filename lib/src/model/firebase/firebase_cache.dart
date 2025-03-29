import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/model/cards.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_repository.dart';

class CardStatsCache {
  final FirebaseFirestore _firestore;

  final User _user;

  final Map<String, CardStats> _cache = {};

  CardStatsCache(this._firestore, this._user);

  Future<void> init() async {
    final collection = _firestore
        .userCollection(cardStatsCollectionName, _user.uid)
        .withCardStatsConverter;
    final cardStats = await collection
        .get()
        .then((value) => value.docs.map((doc) => doc.data()));
    _cache.addAll(Map.fromEntries(
        cardStats.map((stats) => MapEntry(stats.idValue, stats))));
    collection.get();
  }
}