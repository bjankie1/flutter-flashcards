import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flashcards/src/login/login_controller.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flashcards/firebase_options.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    final loginController = ref.read(loginControllerProvider.notifier);
    final l10n = context.l10n;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Redirect to home page after successful login
    if (loginState.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Scaffold(
          body: isWide
              ? Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: kDebugMode
                                  ? SignInScreen(
                                      providers: [
                                        EmailAuthProvider(),
                                        GoogleProvider(
                                          clientId: DefaultFirebaseOptions
                                              .GOOGLE_CLIENT_ID,
                                          scopes: [
                                            'email',
                                            'https://www.googleapis.com/auth/documents.readonly',
                                            'https://www.googleapis.com/auth/drive.readonly',
                                          ],
                                        ),
                                      ],
                                    )
                                  : _LoginForm(
                                      loginState: loginState,
                                      loginController: loginController,
                                      emailController: emailController,
                                      passwordController: passwordController,
                                      l10n: l10n,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/login_background.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Card(
                        elevation: 8,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: kDebugMode
                              ? SignInScreen(
                                  providers: [
                                    EmailAuthProvider(),
                                    GoogleProvider(
                                      clientId: DefaultFirebaseOptions
                                          .GOOGLE_CLIENT_ID,
                                      scopes: [
                                        'email',
                                        'https://www.googleapis.com/auth/documents.readonly',
                                        'https://www.googleapis.com/auth/drive.readonly',
                                      ],
                                    ),
                                  ],
                                )
                              : _LoginForm(
                                  loginState: loginState,
                                  loginController: loginController,
                                  emailController: emailController,
                                  passwordController: passwordController,
                                  l10n: l10n,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  final LoginState loginState;
  final LoginController loginController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final dynamic l10n;

  const _LoginForm({
    required this.loginState,
    required this.loginController,
    required this.emailController,
    required this.passwordController,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.signInTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: l10n.emailLabel,
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(color: Colors.black87),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: l10n.passwordLabel,
            border: const OutlineInputBorder(),
            labelStyle: const TextStyle(color: Colors.black87),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            loginController.signInWithEmail(
              emailController.text.trim(),
              passwordController.text.trim(),
            );
          },
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 24),
        if (loginState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              loginState.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loginState.isLoading
                ? null
                : () {
                    loginController.signInWithEmail(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
            child: loginState.isLoading
                ? const CircularProgressIndicator()
                : Text(l10n.signInButton),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                l10n.orLabel,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Image.asset(
              'assets/icon/google_logo.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
            label: Text(
              l10n.signInWithGoogleButton,
              style: const TextStyle(color: Colors.black),
            ),
            onPressed: loginState.isLoading
                ? null
                : () {
                    loginController.signInWithGoogle();
                  },
          ),
        ),
      ],
    );
  }
}
