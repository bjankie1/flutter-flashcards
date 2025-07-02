import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, DocumentSnapshot, SetOptions;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

abstract class FirebaseSerializer<T> {
  Future<T> fromSnapshot(DocumentSnapshot snapshot);
  Future<void> toSnapshot(T value, DocumentReference docRef) async {
    await _updateUserId(docRef);
    await docRef.set(_serialize(value), SetOptions(merge: true));
  }

  Map<String, dynamic> _serialize(T value);

  Future<void> _updateUserId(DocumentReference doc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await doc.set({'userId': user.uid}, SetOptions(merge: true));
    }
  }
}
