# Daymark

A colorful task manager built with Flutter. Organize tasks by category, set priorities and due dates, search and filter your list, and keep your tasks saved on the device.

## Requirements

- Flutter 3.24 or newer (includes Dart 3.5 or newer)
- VS Code Flutter and Dart extensions for editor support
- A browser for the web workflow; Android Studio and Android SDK are only needed for Android builds

## Run in GitHub Codespaces

From the project folder, run:

```bash
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Forward port `8080` from the Codespaces **Ports** tab, then open its forwarded URL. For desktop development, `flutter run` selects an available device.

## Build an Android APK

Install and configure the Android SDK, accept its licenses with `flutter doctor --android-licenses`, then run:

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Task storage

Tasks are stored locally on the current device. They are not synced between devices or accounts.
