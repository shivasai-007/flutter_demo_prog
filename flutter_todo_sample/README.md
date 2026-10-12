# Flutter Todo List Sample

A simple Flutter app that lets you:
- Add tasks
- Mark tasks as completed
- Delete tasks
- View a progress bar

## Run in VS Code

1. Install Flutter and the Flutter/Dart VS Code extensions.
2. Extract this ZIP.
3. Open the `flutter_todo_sample` folder in VS Code.
4. Open Terminal > New Terminal and run:

   ```powershell
   flutter pub get
   flutter run
   ```

## Build an Android APK

From the project root, run:

```powershell
flutter build apk --release
```

The APK will be created at:

`build/app/outputs/flutter-apk/app-release.apk`

## Note

This starter version stores tasks in memory only. Tasks reset when the app is fully closed. Persistent storage can be added later.
