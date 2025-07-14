import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async {
    return MockGoogleSignInAccount();
  }

  @override
  Future<GoogleSignInAccount?> signInSilently({
    bool reAuthenticate = false,
    bool suppressErrors = false,
  }) async {
    return MockGoogleSignInAccount();
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    return MockGoogleSignInAccount();
  }

  @override
  Future<GoogleSignInAccount?> disconnect() async {
    return MockGoogleSignInAccount();
  }
}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  @override
  String get email => 'test@example.com';

  @override
  String get displayName => 'Test User';

  @override
  String get id => 'test_user_id';

  @override
  String? get photoUrl => null;

  @override
  String get idToken => 'mock_id_token';

  @override
  String? get serverAuthCode => null;

  @override
  Future<GoogleSignInAuthentication> get authentication async {
    return MockGoogleSignInAuthentication();
  }
}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {
  @override
  String? get accessToken => 'mock_access_token';

  @override
  String? get idToken => 'mock_id_token';

  @override
  String? get serverAuthCode => null;
}
