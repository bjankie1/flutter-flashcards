# Release new binary to App Store

See https://docs.flutter.dev/deployment/android for details.

### One time setup

1. Create keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Reference the keystore from the app - edit `android/key.properties`
3. Navigate to Google Play console
   console: https://play.google.com/console/u/0/developers/5710042288198755093/app-list
4. Go to specific
   App https://play.google.com/console/u/0/developers/5710042288198755093/app/4975187421745848975/app-dashboard
5. Go to `Test and release` -> `Testing` -> `Closed testing`
6. Create testing track -> `Create track` in the top right corner.

### Build and release

1. Build app bundle
   ```bash
   flutter build appbundle
   ```
2. Navigate to Google Play console.
3. Go to `Test and release` -> `Testing` -> `Closed testing`
4. Select `Manage` on your testing track.
5. Click `Create new release` in the top right corner.
6. 