# Coinleaf — Personal Finance Tracker

Track. Save. Thrive. Coinleaf helps you record expenses and visualize your monthly spending breakdown with a clean, offline-first experience.

## Features
- Fast expense tracking with local persistence (Sqflite)
- Monthly summary with charts (fl_chart)
- Category-based breakdown and totals
- BLoC state management and DI via get_it
- Light, performant UI with Google Fonts and SVG support

## Requirements
- Flutter SDK compatible with Dart 3.8.1
- Android Studio / Xcode for platform builds

## Tech Stack
- Flutter (Dart >= 3.8)
- State: flutter_bloc, equatable
- Storage: sqflite, shared_preferences, path_provider
- Networking: dio (extensible for future data sources)
- Utils: intl, uuid
- Charts: fl_chart
- DI: get_it

## Project Structure
- lib/
  - core/ … shared constants, theme, utils
  - data/ … models, datasources, repositories
  - domain/ … entities, repositories, usecases
  - presentation/
    - bloc/ … BLoCs and states/events
    - pages/ … screens (e.g., Summary page)
    - widgets/ … UI components
  - dependency_injection.dart … service locator setup
- assets/ … images (app icon, etc.)
- android/, ios/ … platform projects

## Getting Started
1) Ensure your Flutter SDK supports Dart 3.8.1 (flutter --version).
2) Install dependencies:
   - flutter pub get
3) (Optional) Generate app icons from assets/coinleaf.png:
   - dart run flutter_launcher_icons
4) Run the app on a device/emulator:
   - flutter run

## Building
### Android – APK (Release)
- Quick unsigned APK:
  - flutter build apk --release
- Split per ABI (smaller APKs for Play Store testing):
  - flutter build apk --release --split-per-abi
  - Output: build/app/outputs/flutter-apk/
- Android App Bundle (recommended for Play Console):
  - flutter build appbundle --release
  - Output: build/app/outputs/bundle/release/app-release.aab

### Signing for Distribution (Android)
1) Create a keystore (Windows example):
   - keytool -genkey -v -keystore %USERPROFILE%\.keystores\coinleaf.jks -keyalg RSA -keysize 2048 -validity 10000 -alias coinleaf
2) Create android/key.properties:
   - storePassword=YOUR_STORE_PASSWORD
   - keyPassword=YOUR_KEY_PASSWORD
   - keyAlias=coinleaf
   - storeFile=C:\\Users\\<you>\\.keystores\\coinleaf.jks
3) Ensure android/app/build.gradle(.kts) reads key.properties for release signing.
4) Build release as above.

### iOS – IPA (Release)
- Open ios/Runner in Xcode, set your team and signing.
- Product > Archive, then distribute (Ad Hoc/TestFlight/App Store).

## App Icon
- Source: assets/coinleaf.png
- Config is under flutter_launcher_icons in pubspec.yaml
- Regenerate after changing the image:
  - dart run flutter_launcher_icons
- Make icon appear bigger:
  - Remove extra transparent padding around the logo in assets/coinleaf.png, or
  - Provide a tighter-cropped image for adaptive_icon_foreground in pubspec.yaml.

## Testing and Lints
- Lints: flutter analyze
- Tests: flutter test

## Troubleshooting
- Charts show “No expense data”: ensure expenses exist for the selected month/year. After schema/asset changes run: flutter clean && flutter pub get.
- Android signing errors: verify key.properties paths and passwords.

## License
Proprietary/Private unless a license is added.
