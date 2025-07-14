import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

import '../../firebase_options.dart';

class GoogleDocPicker extends StatefulWidget {
  @override
  GoogleDocPickerState createState() => GoogleDocPickerState();
}

class GoogleDocPickerState extends State<GoogleDocPicker> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _extractDocIdFromUrl(String url) {
    // Extract document ID from various Google Doc URL formats
    final patterns = [
      RegExp(r'/document/d/([a-zA-Z0-9-_]+)'),
      RegExp(r'/document/d/([a-zA-Z0-9-_]+)/edit'),
      RegExp(r'/document/d/([a-zA-Z0-9-_]+)/view'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  void _loadFromUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterGoogleDocUrl)),
      );
      return;
    }

    final docId = _extractDocIdFromUrl(url);
    if (docId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.invalidGoogleDocUrl)));
      return;
    }

    Navigator.of(context).pop(docId);
  }

  Future<List<drive.File>> _fetchGoogleDocs() async {
    final googleSignIn = GoogleSignIn(
      clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID,
      scopes: [drive.DriveApi.driveReadonlyScope],
    );

    var account = await googleSignIn.signInSilently();
    account ??= await googleSignIn.signIn();

    if (account == null) {
      throw Exception('Sign in failed or was cancelled.');
    }

    final hasPermissions = await googleSignIn.requestScopes([
      drive.DriveApi.driveReadonlyScope,
    ]);
    if (!hasPermissions) {
      throw Exception('Failed to get necessary permissions.');
    }

    final client = await googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Failed to get authenticated client');
    }

    final driveApi = drive.DriveApi(client);
    final fileList = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.document'",
      $fields: 'files(id, name)',
    );

    return fileList.files ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Use simple URL input for local development
    if (kDebugMode) {
      return AlertDialog(
        title: Text(context.l10n.selectGoogleDoc),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.enterGoogleDocUrl,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: context.l10n.googleDocUrlHint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _urlController.clear(),
                ),
              ),
              onSubmitted: (_) => _loadFromUrl(),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.googleDocUrlExample,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _loadFromUrl,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.loadButton),
          ),
        ],
      );
    }

    // Use Google Drive API for production
    return AlertDialog(
      title: Text(context.l10n.selectGoogleDoc),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<drive.File>>(
          future: _fetchGoogleDocs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No Google Docs found.');
            }

            final files = snapshot.data!;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  title: Text(file.name ?? 'No name'),
                  onTap: () {
                    Navigator.of(context).pop(file.id);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancelButtonLabel),
        ),
      ],
    );
  }
}
