# watchlisttv

Provide a trakt.tv watchlist

## Getting Started

Build the env file after changes:

```
flutter pub run build_runner build -d 
```

Building for install on TV

```
flutter build apk --dart-define-from-file=.env
adb connect <device IP>
adb install build\app\outputs\flutter-apk\app-release.apk
```