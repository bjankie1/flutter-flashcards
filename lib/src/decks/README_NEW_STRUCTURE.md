# Decks Module - New Structure

This document describes the new organized structure for the decks module that decouples widgets from repository and business logic using Riverpod controllers.

## Directory Structure

```
lib/src/decks/
├── deck_groups/          # Deck groups functionality
│   ├── deck_groups_controller.dart
│   ├── deck_groups_controller.g.dart
│   ├── deck_groups_page.dart
│   ├── deck_groups_widget.dart
│   ├── deck_group_selection_list.dart
│   ├── deck_group_horizontal_list.dart
│   └── index.dart
├── cards_list/           # Cards list functionality
│   ├── cards_list_controller.dart
│   ├── cards_list.dart
│   ├── cards_list_widgets.dart
│   ├── deck_details_controller.dart
│   ├── deck_details.dart
│   └── deck_details_page.dart
├── deck_list/            # Deck list functionality
│   ├── decks_controller.dart
│   ├── decks_controller.g.dart
│   ├── decks_list.dart
│   ├── deck_list_item.dart
│   ├── deck_info_controller.dart
│   ├── deck_info_controller.g.dart
│   ├── deck_info_widget.dart
│   ├── deck_mastery_controller.dart
│   ├── deck_mastery_controller.g.dart
│   ├── deck_mastery_progress.dart
│   ├── deck_cards_to_review_controller.dart
│   ├── deck_cards_to_review_controller.g.dart
│   ├── deck_cards_to_review_widget.dart
│   └── index.dart
├── card_edit.dart                    # Card editing functionality
├── card_edit_page.dart               # Card edit page
├── cards_import.dart                 # Cards import functionality
├── deck_generate_page.dart           # Deck generation page
├── deck_generate_from_google_doc_page.dart
├── deck_generate_from_google_doc_controller.dart
├── deck_sharing.dart                 # Deck sharing functionality
├── shared_decks.dart                 # Shared decks functionality
├── editable_text.dart                # Editable text widget
├── google_doc_picker.dart            # Google Doc picker
├── provisionary_cards_add.dart       # Provisional cards addition
├── provisionary_card_complete.dart   # Provisional card completion
├── README_NEW_STRUCTURE.md           # This documentation
└── README_RIVERPOD_MIGRATION.md      # Migration guide
```

## Architecture Overview

### 1. Deck Groups (`deck_groups/`)

Contains all functionality related to organizing decks into groups:

- **`DeckGroupsController`**: Manages deck groups operations
  - Loading decks organized by groups
  - Creating, updating, and deleting deck groups
  - Adding/removing decks from groups
  - Refreshing data
- **`DeckGroupsPage`**: Main page for deck groups management
- **`DeckGroupsWidget`**: Main widget for displaying deck groups
- **`DeckGroupSelectionList`**: Widget for selecting deck groups
- **`DeckGroupHorizontalList`**: Horizontal list display of deck groups

### 2. Cards List (`cards_list/`)

Contains functionality for managing and displaying cards within decks:

- **`CardsListController`**: Manages cards list operations
- **`CardsList`**: Main widget for displaying cards
- **`CardsListWidgets`**: Reusable card-related widgets
- **`DeckDetailsController`**: Manages deck details operations
- **`DeckDetails`**: Widget for displaying deck details
- **`DeckDetailsPage`**: Page for deck details

### 3. Deck List (`deck_list/`)

Contains functionality for displaying and managing the list of decks:

- **`DecksController`**: Manages deck list operations
- **`DecksList`**: Main widget for displaying deck list
- **`DeckListItem`**: Individual deck item widget
- **`DeckInfoController`**: Manages deck information operations
- **`DeckInfoWidget`**: Widget for displaying deck information
- **`DeckMasteryController`**: Manages deck mastery tracking
- **`DeckMasteryProgress`**: Widget for displaying mastery progress
- **`DeckCardsToReviewController`**: Manages cards to review operations
- **`DeckCardsToReviewWidget`**: Widget for displaying cards to review

### 4. Standalone Components

Individual files for specific functionality:

- **Card Editing**: `card_edit.dart`, `card_edit_page.dart`
- **Cards Import**: `cards_import.dart`
- **Deck Generation**: `deck_generate_page.dart`, `deck_generate_from_google_doc_page.dart`
- **Deck Sharing**: `deck_sharing.dart`, `shared_decks.dart`
- **Google Docs Integration**: `google_doc_picker.dart`
- **Provisional Cards**: `provisionary_cards_add.dart`, `provisionary_card_complete.dart`
- **UI Components**: `editable_text.dart`

## Migration Benefits

### 1. Separation of Concerns
- **Business Logic**: Moved to controllers
- **UI Logic**: Remains in widgets
- **Data Access**: Abstracted through controllers

### 2. Testability
- Controllers can be unit tested independently
- Widgets can be tested with mocked providers
- Business logic is isolated from UI

### 3. Reusability
- Controllers can be shared across multiple widgets
- Widgets are more focused and reusable
- Providers can be composed and combined

### 4. State Management
- Automatic caching and dependency tracking
- Built-in error handling with `AsyncValue`
- Reactive updates when data changes

## Usage Examples

### Using the Deck Groups Controller

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckGroupsAsync = ref.watch(deckGroupsControllerProvider);
    
    return deckGroupsAsync.when(
      data: (groups) => DeckGroupsList(groups: groups),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

### Using the Decks Controller

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksControllerProvider);
    
    return decksAsync.when(
      data: (decks) => DecksList(decks: decks),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

### Using the Cards List Controller

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsListControllerProvider);
    
    return cardsAsync.when(
      data: (cards) => CardsList(cards: cards),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

### Performing Actions

```dart
// Update a deck group
await ref
    .read(deckGroupsControllerProvider.notifier)
    .updateDeckGroup(updatedGroup);

// Create a new deck group
await ref
    .read(deckGroupsControllerProvider.notifier)
    .createDeckGroup('New Group', 'Description');

// Refresh decks list
await ref
    .read(decksControllerProvider.notifier)
    .refresh();
```

### Using Specific Providers

```dart
// Watch deck info for a specific deck
final deckInfoAsync = ref.watch(
  deckInfoControllerProvider(deckId),
);

// Watch mastery progress for a deck
final masteryAsync = ref.watch(
  deckMasteryControllerProvider(deckId),
);

// Watch cards to review for a deck
final cardsToReviewAsync = ref.watch(
  deckCardsToReviewControllerProvider(deckId),
);
```

## Migration Path

### From Legacy to New Structure

1. **Replace `RepositoryLoader`** with `ConsumerWidget`
2. **Use controllers** instead of direct repository access
3. **Watch providers** instead of calling repository methods
4. **Handle async states** with `AsyncValue.when()`

### Example Migration

```dart
// Before (Legacy)
class OldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader(
      fetcher: (repository) => repository.loadDecksInGroups(),
      builder: (context, groups, _) => DeckGroupsList(groups: groups),
    );
  }
}

// After (New)
class NewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(deckGroupsControllerProvider);
    
    return groupsAsync.when(
      data: (groups) => DeckGroupsList(groups: groups),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

### Migration from Direct Repository Access

```dart
// Before (Direct repository access)
class OldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Deck>>(
      future: repository.getDecks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DecksList(decks: snapshot.data!);
        }
        return CircularProgressIndicator();
      },
    );
  }
}

// After (Using controllers)
class NewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksControllerProvider);
    
    return decksAsync.when(
      data: (decks) => DecksList(decks: decks),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

## Best Practices

1. **Keep controllers focused**: Each controller should handle a single domain
2. **Use `AsyncValue`**: Always wrap async data for proper loading/error states
3. **Invalidate providers**: Use `ref.invalidate()` to refresh data when needed
4. **Watch vs Read**: Use `watch` for reactive data and `read` for one-time access
5. **Error handling**: Always handle error states in your widgets

## Future Improvements

1. **Consolidate standalone files**: Move standalone components into appropriate subdirectories
   - Move card editing files to a `card_editing/` subdirectory
   - Move deck generation files to a `deck_generation/` subdirectory
   - Move sharing files to a `deck_sharing/` subdirectory

2. **Add comprehensive testing**: 
   - Unit tests for all controllers
   - Widget tests for all major widgets
   - Integration tests for user flows

3. **Implement caching strategies**: 
   - Use Riverpod's built-in caching capabilities more effectively
   - Add offline support for core functionality
   - Implement smart data invalidation

4. **Performance optimization**: 
   - Use `select` for fine-grained reactivity
   - Implement pagination for large lists
   - Add lazy loading for card images

5. **Code organization improvements**:
   - Create shared models and types
   - Extract common UI components
   - Standardize error handling patterns

6. **Documentation enhancements**:
   - Add API documentation for all controllers
   - Create usage examples for each submodule
   - Document testing patterns and best practices 