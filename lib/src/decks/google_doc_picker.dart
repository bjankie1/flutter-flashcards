import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;

import '../../firebase_options.dart';

class GoogleDocPicker extends StatefulWidget {
  @override
  _GoogleDocPickerState createState() => _GoogleDocPickerState();
}

class _GoogleDocPickerState extends State<GoogleDocPicker> {
  Future<List<drive.File>>? _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = _fetchGoogleDocs();
  }

  Future<List<drive.File>> _fetchGoogleDocs() async {
    final googleSignIn = GoogleSignIn(
      clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID,
      scopes: [drive.DriveApi.driveReadonlyScope],
    );

    var account = await googleSignIn.signInSilently();
    if (account == null) {
      account = await googleSignIn.signIn();
    }

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
    return AlertDialog(
      title: Text('Select a Google Doc'),
      content: Container(
        width: double.maxFinite,
        child: FutureBuilder<List<drive.File>>(
          future: _filesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No Google Docs found.');
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
