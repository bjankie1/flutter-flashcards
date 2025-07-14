# Layout Constraints System

This directory contains the layout constraints system that provides responsive design capabilities to all child widgets in the Flutter Flashcards app.

## Overview

The layout constraints system consists of:

1. **`LayoutConstraintsData`** - A data class containing layout constraints and responsive properties
2. **`LayoutConstraints`** - An InheritedWidget that provides layout data to the widget tree
3. **`LayoutConstraintsExtension`** - Extension methods on BuildContext for easy access

## How It Works

The `BaseLayout` widget wraps all app content with a `LayoutBuilder` and provides the layout constraints through an `InheritedWidget`. This allows any child widget to access the current layout constraints and responsive properties without needing its own `LayoutBuilder`.

## Usage

### Basic Usage with Extension Methods

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the screen is mobile
    if (context.isMobileLayout) {
      return MobileLayout();
    } else {
      return DesktopLayout();
    }
  }
}
```

### Accessing Layout Data Directly

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final constraints = context.layoutConstraints;
    
    return Container(
      width: constraints.maxWidth * 0.8,
      child: Text('Screen width: ${constraints.maxWidth}px'),
    );
  }
}
```

### Responsive Design Patterns

#### 1. Conditional Rendering

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      if (context.isMobileLayout) ...[
        MobileHeader(),
        MobileContent(),
      ] else ...[
        DesktopHeader(),
        DesktopContent(),
      ],
    ],
  );
}
```

#### 2. Responsive Grid

```dart
Widget build(BuildContext context) {
  int columns;
  if (context.isAboveTabletBreakpoint) {
    columns = 4;
  } else if (context.isAboveMobileBreakpoint) {
    columns = 2;
  } else {
    columns = 1;
  }

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
    ),
    // ... rest of grid implementation
  );
}
```

#### 3. Responsive Typography

```dart
Widget build(BuildContext context) {
  double fontSize;
  if (context.isAboveTabletBreakpoint) {
    fontSize = 24.0;
  } else if (context.isAboveMobileBreakpoint) {
    fontSize = 20.0;
  } else {
    fontSize = 16.0;
  }

  return Text(
    'Responsive Text',
    style: TextStyle(fontSize: fontSize),
  );
}
```

## Available Properties

### Extension Methods on BuildContext

- `context.isMobileLayout` - True if screen width < 600px
- `context.isWideLayout` - True if screen width >= 600px
- `context.layoutMaxWidth` - Maximum available width
- `context.layoutMaxHeight` - Maximum available height
- `context.isAboveMobileBreakpoint` - True if width > 600px
- `context.isAboveTabletBreakpoint` - True if width > 900px

### LayoutConstraintsData Properties

- `constraints.maxWidth` - Maximum available width
- `constraints.maxHeight` - Maximum available height
- `constraints.isMobile` - True if mobile layout
- `constraints.isWide` - True if wide layout
- `constraints.isNarrow` - True if narrow layout
- `constraints.isAboveBreakpoint(double breakpoint)` - Check if width > breakpoint
- `constraints.isBelowBreakpoint(double breakpoint)` - Check if width <= breakpoint

## Breakpoints

The system uses these standard breakpoints:

- **Mobile**: < 600px
- **Tablet**: 600px - 900px
- **Desktop**: > 900px

## Benefits

1. **Performance**: No need for multiple `LayoutBuilder` widgets throughout the app
2. **Consistency**: All widgets use the same layout constraints
3. **Maintainability**: Centralized responsive logic
4. **Type Safety**: Strongly typed properties and methods
5. **Ease of Use**: Simple extension methods for common use cases

## Migration from Existing Code

If you have existing code using `LayoutBuilder`, you can migrate it to use the new system:

### Before (with LayoutBuilder)
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isMobile = constraints.maxWidth < 600;
    return isMobile ? MobileWidget() : DesktopWidget();
  },
)
```

### After (with LayoutConstraints)
```dart
context.isMobileLayout ? MobileWidget() : DesktopWidget()
```

## Example

See `layout_constraints_example.dart` for a comprehensive example of how to use all the features of the layout constraints system.

## Best Practices

1. **Use extension methods** for simple responsive checks
2. **Access constraints data directly** when you need specific dimensions
3. **Define breakpoints as constants** for consistency across the app
4. **Test on different screen sizes** to ensure responsive behavior works correctly
5. **Use semantic names** like `isMobileLayout` instead of raw width comparisons 