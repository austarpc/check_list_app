# muhasabat

Muhasabat (মুহাসাবাত) is a daily Islamic self-accountability checklist app built with Flutter.

## Build

### Release APK

```bash
flutter pub get
flutter build apk --release
```

The release APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

### GitHub Actions

Pushing to `master` (or manually dispatching the **Build Release APK** workflow) builds a
release APK and uploads it as the `muhasabat-release-apk` artifact.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
