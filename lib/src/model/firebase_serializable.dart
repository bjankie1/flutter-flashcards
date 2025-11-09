abstract class FirebaseSerializable<T> {
  Map<String, dynamic> toJson();

  String? get idValue;
}
