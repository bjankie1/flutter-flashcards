# Riverpod Migration Guide

This document explains how to migrate from the `RepositoryLoader` pattern to a Riverpod-based architecture that decouples widgets from the `FirebaseCardsRepository`.

## Overview

The migration introduces:
1. **Controller Pattern**: Business logic is moved to controller classes
2. **Riverpod State Management**: Replaces Provider with Riverpod for better state management
3. **Decoupled Architecture**: Widgets are no longer directly coupled to the repository

## Architecture Components

### 1. Controller Class (`DecksController`)

The controller encapsulates business logic and manages state:

```dart
class DecksController extends StateNotifier<AsyncValue<Iterable<model.Deck>>> {
  final CardsRepository _repository;

  DecksController(this._repository) : super(const AsyncValue.loading()) {
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    // Business logic for loading decks
  }

  Future<void> saveDeck(model.Deck deck) async {
    // Business logic for saving decks
  }

  Future<void> deleteDeck(String deckId) async {
    // Business logic for deleting decks
  }
}
```

### 2. Riverpod Providers

Providers are generated using the `@riverpod` annotation:

```dart
@riverpod
DecksController decksController(DecksControllerRef ref) {
  final repository = ref.watch(cardsRepositoryProvider);
  return DecksController(repository);
}

@riverpod
AsyncValue<List<model.Deck>> sortedDecks(SortedDecksRef ref) {
  final decksAsync = ref.watch(decksControllerProvider).state;
  
  return decksAsync.when(
    data: (decks) {
      final sortedDecks = decks.toList();
      sortedDecks.sort((deck1, deck2) => deck1.name.compareTo(deck2.name));
      return AsyncValue.data(sortedDecks);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}
```

### 3. Riverpod Widgets

Widgets use `ConsumerWidget` and watch providers:

```dart
class DeckListRiverpod extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedDecksAsync = ref.watch(sortedDecksProvider);

    return sortedDecksAsync.when(
      data: (decks) => ListView.builder(/* ... */),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

## Migration Steps

### Step 1: Add Dependencies

Add Riverpod dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.0
```

### Step 2: Update Main App

Wrap your app with `ProviderScope` and provide the repository:

```dart
runApp(
  ProviderScope(
    overrides: [
      cardsRepositoryProvider.overrideWithValue(repository),
    ],
    child: MultiProvider(
      // ... existing providers
      child: const FlashcardsApp(),
    ),
  ),
);
```

### Step 3: Create Controller

Create a controller class for your data:

```dart
class YourController extends StateNotifier<AsyncValue<YourDataType>> {
  final CardsRepository _repository;

  YourController(this._repository) : super(const AsyncValue.loading()) {
    _loadData();
  }

  Future<void> _loadData() async {
    // Load data logic
  }

  Future<void> performAction() async {
    // Action logic
  }
}
```

### Step 4: Create Providers

Use the `@riverpod` annotation to create providers:

```dart
@riverpod
YourController yourController(YourControllerRef ref) {
  final repository = ref.watch(cardsRepositoryProvider);
  return YourController(repository);
}

@riverpod
AsyncValue<ProcessedDataType> processedData(ProcessedDataRef ref) {
  final dataAsync = ref.watch(yourControllerProvider).state;
  
  return dataAsync.when(
    data: (data) => AsyncValue.data(processData(data)),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}
```

### Step 5: Update Widgets

Replace `RepositoryLoader` with `ConsumerWidget`:

```dart
// Before
class OldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryLoader<DataType>(
      fetcher: (repository) => repository.loadData(),
      builder: (context, data, repository) => YourWidget(data: data),
    );
  }
}

// After
class NewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yourDataProvider);
    
    return dataAsync.when(
      data: (data) => YourWidget(data: data),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}
```

## Benefits

1. **Separation of Concerns**: Business logic is separated from UI logic
2. **Testability**: Controllers can be easily unit tested
3. **Reusability**: Providers can be shared across multiple widgets
4. **Type Safety**: Riverpod provides better type safety than Provider
5. **Performance**: Automatic caching and dependency tracking
6. **Error Handling**: Built-in error handling with AsyncValue

## Best Practices

1. **Keep Controllers Small**: Each controller should handle a single domain
2. **Use AsyncValue**: Always wrap async data in AsyncValue for proper loading/error states
3. **Invalidate Providers**: Use `ref.invalidate()` to refresh data when needed
4. **Watch vs Read**: Use `watch` for reactive data and `read` for one-time access
5. **Error Handling**: Always handle error states in your widgets

## Example Usage

See `DeckListRiverpod` in `decks_list_riverpod.dart` for a complete example of:
- Controller implementation
- Provider creation
- Widget usage
- Error handling
- Data refresh

## Migration Checklist

- [ ] Add Riverpod dependencies
- [ ] Update main.dart with ProviderScope
- [ ] Create controller classes for each domain
- [ ] Create providers using @riverpod annotation
- [ ] Update widgets to use ConsumerWidget
- [ ] Replace RepositoryLoader with provider watching
- [ ] Test all functionality
- [ ] Remove old RepositoryLoader usage 