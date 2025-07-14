import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/model/enums.dart';

/// Widget for displaying category images based on DeckCategory enum
final class CategoryImage extends StatelessWidget {
  final DeckCategory category;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CategoryImage({
    super.key,
    required this.category,
    required this.size,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  /// Maps DeckCategory enum to corresponding image asset path
  String _getImagePath(DeckCategory category) {
    switch (category) {
      case DeckCategory.language:
        return 'assets/images/categories/language.png';
      case DeckCategory.history:
        return 'assets/images/categories/history.png';
      case DeckCategory.science:
        return 'assets/images/categories/science.png';
      case DeckCategory.biology:
        return 'assets/images/categories/biology.png';
      case DeckCategory.geography:
        return 'assets/images/categories/geography.png';
      case DeckCategory.math:
        return 'assets/images/categories/math.png';
      case DeckCategory.other:
        return 'assets/images/categories/other.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImagePath(category);

    Widget imageWidget = Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a colored container with category name if image fails to load
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getCategoryColor(category),
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              category.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    // Apply borderRadius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  /// Returns a color for each category as fallback
  Color _getCategoryColor(DeckCategory category) {
    switch (category) {
      case DeckCategory.language:
        return Colors.blue;
      case DeckCategory.history:
        return Colors.orange;
      case DeckCategory.science:
        return Colors.green;
      case DeckCategory.biology:
        return Colors.teal;
      case DeckCategory.geography:
        return Colors.brown;
      case DeckCategory.math:
        return Colors.purple;
      case DeckCategory.other:
        return Colors.grey;
    }
  }
}
