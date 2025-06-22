# Version Checking Strategy for Flutter Flashcards

This document describes the robust version checking strategy implemented for the Flutter Flashcards web application.

## Overview

The version checking system provides:
- **Automatic periodic checks** every 10 minutes
- **Manual update checks** from the settings page
- **Visual update notifications** with banners and buttons
- **Service worker integration** for better caching control
- **Firebase Remote Config integration** for centralized version management

## Components

### 1. Remote Config Provider (`lib/src/model/firebase/remote_config.dart`)

Handles Firebase Remote Config integration for version checking:

```dart
// Remote config parameters:
// - app_version: "1.0.2" (semantic version)
// - app_build_number: "121" (build number)
// - update_message: "Custom update message" (optional)
// - update_required: "true/false" (force update)
```

### 2. App Info Service (`lib/src/app_info.dart`)

Manages version checking state and periodic updates:

- Extends `ChangeNotifier` for reactive UI updates
- Automatically starts periodic checking on web platforms
- Provides manual update checking functionality
- Handles update installation via JavaScript interop

### 3. Version Update Banner (`lib/src/common/version_update_banner.dart`)

UI components for update notifications:

- `VersionUpdateBanner`: Full-width banner at the top of the app
- `VersionUpdateNotification`: Small notification badge
- `UpdateCheckingIndicator`: Shows checking status

### 4. Service Worker (`web/sw.js`)

Handles caching and version detection:

- Caches static files and Flutter assets
- Provides background version checking
- Manages cache invalidation for updates
- Supports periodic background sync

### 5. Web Integration (`web/index.html`)

JavaScript integration for web-specific functionality:

- Service worker registration
- JavaScript interop for app reloading
- Update notification handling

## Usage

### For Users

1. **Automatic Updates**: The app automatically checks for updates every 10 minutes
2. **Update Banner**: When an update is available, a banner appears at the top of the app
3. **Manual Check**: Users can manually check for updates in Settings → App Version
4. **Update Installation**: Click "Update Now" to install the latest version

### For Developers

#### Setting Up Firebase Remote Config

1. Go to Firebase Console → Remote Config
2. Add the following parameters:

```
app_version: "1.0.2"
app_build_number: "121"
update_message: "New features and bug fixes available!"
update_required: "false"
```

#### Deploying Updates

1. Update the version in `pubspec.yaml`:
   ```yaml
   version: 1.0.2+121
   ```

2. Run the deploy script:
   ```bash
   ./deploy.sh
   ```

3. Update Firebase Remote Config with the new version information

#### Testing Version Checking

1. **Local Testing**: Use Firebase Remote Config to set a higher version
2. **Manual Check**: Use the "Check for Updates" button in settings
3. **Automatic Check**: Wait for the 10-minute interval or trigger manually

## Configuration

### Update Check Interval

The update check interval is configured in `lib/src/app_info.dart`:

```dart
static const Duration _checkInterval = Duration(minutes: 10);
```

### Service Worker Cache Names

Cache names are automatically updated during deployment but can be manually configured in `web/sw.js`:

```javascript
const CACHE_NAME = 'flutter-flashcards-v1.0.2+121';
const STATIC_CACHE_NAME = 'flutter-flashcards-static-v1.0.2+121';
```

### Localization

All update-related strings are localized in:
- `lib/l10n/app_en.arb` (English)
- `lib/l10n/app_pl.arb` (Polish)

## Troubleshooting

### Update Not Showing

1. Check Firebase Remote Config values
2. Verify version comparison logic
3. Check browser console for errors
4. Ensure service worker is registered

### Cache Issues

1. Clear browser cache
2. Check service worker cache names
3. Verify cache invalidation logic
4. Test with incognito mode

### Version Comparison

The version comparison uses semantic versioning:
1. Compares major.minor.patch versions
2. Falls back to build number comparison
3. Handles invalid version formats gracefully

## Security Considerations

- Version information is public and not sensitive
- Update checks use Firebase Remote Config for reliability
- Service worker provides offline functionality
- No user data is transmitted during version checks

## Future Enhancements

- [ ] Progressive Web App (PWA) installation prompts
- [ ] Background sync for offline updates
- [ ] Delta updates for smaller downloads
- [ ] Update rollback functionality
- [ ] A/B testing for update messages 