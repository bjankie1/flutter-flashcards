import 'dart:convert'; // For encoding the email string to bytes
import 'package:crypto/crypto.dart'; // For SHA-256 hashing

extension HashingExtension on String {
  String get sha256Digest {
    var bytes = utf8.encode(this); // Convert the email string to bytes
    var digest = sha256.convert(bytes); // Calculate the SHA-256 hash
    return digest.toString(); // Convert the digest to a hexadecimal string
  }
}
