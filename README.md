# Hero App Flutter

Flutter client for the Hero App project.

## Structure

- `lib/app`: app bootstrap, bindings, and root shell
- `lib/core`: shared controllers, network, models, services, and session flow
- `lib/features`: feature-first pages, page controllers, and widgets
- `lib/shared`: reusable UI building blocks
- `test`: unit and widget coverage for core and high-risk UI flows

## Getting Started

1. Run `flutter pub get`
2. Ensure the local `.env` matches the target backend
3. Run `flutter test`
4. Run `flutter analyze`
5. Start the app with `flutter run`
