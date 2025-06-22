# Decks Module - New Structure

This document describes the new organized structure for the decks module that decouples widgets from repository and business logic using Riverpod controllers.

## Directory Structure

```
lib/src/decks/
├── controllers/           # Riverpod controllers for business logic
│   ├── deck_groups_controller.dart
│   └── deck_groups_controller.g.dart
├── pages/                 # Page-level widgets
│   ├── decks_page.dart           # Legacy Provider-based page
│   └── decks_page_riverpod.dart  # New Riverpod-based page
├── widgets/               # Reusable widget components
│   ├── deck_groups.dart          # Legacy widget
│   └── deck_groups_widget.dart   # New Riverpod-based widget
├── deck_list/            # Existing deck list components
├── index.dart            # Module exports
└── README_NEW_STRUCTURE.md
```

## Architecture Overview

### 1. Controllers (`controllers/`)

Controllers encapsulate business logic and manage state using Riverpod:

- **`DeckGroupsController`**: Manages deck groups operations
  - Loading decks organized by groups
  - Creating, updating, and deleting deck groups
  - Adding/removing decks from groups
  - Refreshing data

### 2. Pages (`pages/`)

Page-level widgets that compose the UI:

- **`DecksPageRiverpod`**: New Riverpod-based main decks page
  - Uses `ConsumerWidget` for Riverpod integration
  - Composes widgets from the `widgets/` directory
  - Handles page-level interactions

### 3. Widgets (`widgets/`)

Reusable widget components:

- **`DeckGroupsWidget`**: Main widget for displaying deck groups
  - Uses `ConsumerWidget` for Riverpod integration
  - Handles loading, error, and data states
  - Composes smaller widgets like `DeckGroupReviewButton`

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

### Using the Controller

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
```

### Using Providers

```dart
// Watch shared decks
final sharedDecksAsync = ref.watch(sharedDecksProvider);

// Watch review counts for a specific group
final reviewCountsAsync = ref.watch(
  cardsToReviewCountByGroupProvider(groupId),
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

## Best Practices

1. **Keep controllers focused**: Each controller should handle a single domain
2. **Use `AsyncValue`**: Always wrap async data for proper loading/error states
3. **Invalidate providers**: Use `ref.invalidate()` to refresh data when needed
4. **Watch vs Read**: Use `watch` for reactive data and `read` for one-time access
5. **Error handling**: Always handle error states in your widgets

## Future Improvements

1. **Add more controllers**: For cards, reviews, statistics, etc.
2. **Implement caching**: Use Riverpod's built-in caching capabilities
3. **Add offline support**: Handle offline scenarios gracefully
4. **Performance optimization**: Use `select` for fine-grained reactivity
5. **Testing**: Add comprehensive unit and widget tests 