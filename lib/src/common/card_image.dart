import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/cards.dart';
import 'package:flutter_flashcards/src/model/firebase/firebase_storage.dart';
import 'package:provider/provider.dart';

class CardImage extends StatelessWidget {
  const CardImage(
      {super.key,
      required this.cardId,
      required this.placement,
      this.height = 200});

  final String cardId;

  final ImagePlacement placement;

  final double height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context
            .read<StorageService>()
            .cardIllustrationUrl(cardId, placement.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data'));
          }
          final url = snapshot.data;
          if (url == null) {
            return Center(child: Text('No image data'));
          }
          return Image.network(
            url,
            height: height,
          );
        });
  }
}