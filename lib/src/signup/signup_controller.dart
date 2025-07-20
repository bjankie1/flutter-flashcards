import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flashcards/src/services/firebase_auth_service.dart';

class SignupState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const SignupState({this.isLoading = false, this.errorMessage, this.user});

  SignupState copyWith({bool? isLoading, String? errorMessage, User? user}) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class SignupController extends StateNotifier<SignupState> {
  final FirebaseAuthService _authService;

  SignupController(this._authService) : super(const SignupState());

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authService.signUpWithEmail(email, password);
      state = state.copyWith(isLoading: false, user: credential.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userCredential = await _authService.signInWithGoogle();
      state = state.copyWith(isLoading: false, user: userCredential?.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final signupControllerProvider =
    StateNotifierProvider<SignupController, SignupState>(
      (ref) => SignupController(FirebaseAuthService()),
    );
