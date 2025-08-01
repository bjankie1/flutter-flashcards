import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_flashcards/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:http/http.dart' as http;

class GoogleDocData {
  final String title;
  final String content;
  const GoogleDocData({required this.title, required this.content});
}

class GoogleDocReader {
  Future<GoogleDocData> readDoc(String docId) async {
    final googleSignIn = GoogleSignIn(
      clientId: DefaultFirebaseOptions.GOOGLE_CLIENT_ID,
      scopes: [docs.DocsApi.documentsReadonlyScope],
    );
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Sign in failed or was cancelled');
    }

    final http.Client? client = await googleSignIn.authenticatedClient();

    if (client == null) {
      throw Exception('Could not get authenticated client');
    }

    final docsApi = docs.DocsApi(client);

    try {
      final document = await docsApi.documents.get(docId);
      final title = document.title ?? 'Untitled';
      final content = _extractText(document);
      return GoogleDocData(title: title, content: content);
    } catch (e) {
      throw Exception('Failed to load Google Doc: $e');
    } finally {
      client.close();
    }
  }

  String _extractText(docs.Document doc) {
    final buffer = StringBuffer();
    if (doc.body?.content != null) {
      for (final element in doc.body!.content!) {
        if (element.paragraph?.elements != null) {
          for (final paragraphElement in element.paragraph!.elements!) {
            if (paragraphElement.textRun?.content != null) {
              buffer.write(paragraphElement.textRun!.content);
            }
          }
        }
      }
    }
    return buffer.toString();
  }
}
