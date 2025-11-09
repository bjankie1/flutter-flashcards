import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_flashcards/src/common/crypto.dart';
import 'package:flutter_flashcards/src/model/firebase_serializable.dart';

class ProvisionaryCard extends FirebaseSerializable {
  final String id;
  final String text;
  final String? answer;
  final DateTime createdDate;
  final DateTime? finalizedDate;
  final String? resultingCardId;

  ProvisionaryCard(
    this.id,
    this.text,
    this.answer,
    this.createdDate,
    this.finalizedDate,
    this.resultingCardId,
  );

  @override
  String? get idValue => id;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'answer': answer,
      'createdDate': createdDate,
      'finalizedDate': finalizedDate,
      'resultingCardId': resultingCardId,
    };
  }

  factory ProvisionaryCard.fromJson(String id, Map<String, dynamic> json) {
    return ProvisionaryCard(
      id,
      json['text'] as String,
      json['answer'] as String?,
      (json['createdDate'] as Timestamp).toDate(),
      (json['finalizedDate'] as Timestamp?)?.toDate(),
      json['resultingCardId'] as String?,
    );
  }

  factory ProvisionaryCard.fromText(String text) {
    if (text.trim().isEmpty) throw 'Text cannot be empty';
    return ProvisionaryCard(
      text.trim().sha256Digest,
      text.trim(),
      null,
      DateTime.now(),
      null,
      null,
    );
  }

  ProvisionaryCard finalizeWithCard(String resultingCardId) {
    return ProvisionaryCard(
      id,
      text,
      answer,
      createdDate,
      DateTime.now(),
      resultingCardId,
    );
  }
}
