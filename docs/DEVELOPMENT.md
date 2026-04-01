# Development Guide

This guide provides practical local-development steps for contributors working on Nesters.

## 1) Prerequisites

- Flutter SDK compatible with Dart `>=3.2.0 <4.0.0`
- Node.js (18 for functions, >=16 for cloud_run)
- Android Studio / Xcode toolchains for mobile builds

## 2) Clone and Bootstrap

```bash
git clone https://github.com/Dracula-101/Nesters.git
cd Nesters
flutter pub get
cp .env.example .env
```

Populate `.env` with valid keys used by `AppSecretsRepository`.

## 3) Platform and Service Setup

- Add Firebase files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Add Google Maps keys:
  - `android/google-maps.properties`
  - iOS key in `ios/Runner/AppDelegate.swift`

Follow the setup docs for details:

- [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
- [GOOGLE_CONSOLE.md](./GOOGLE_CONSOLE.md)
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)

## 4) Running Locally

### 4.1 Mobile App

```bash
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### 4.2 Functions Emulator

```bash
cd functions
npm install
npm run serve
```

### 4.3 Presence Service

```bash
cd cloud_run
npm install
npm start
```

### 4.4 Admin Panel

```bash
cd admin_panel
npm install
npm run dev
```

## 5) Common Commands

### Flutter

```bash
flutter analyze
flutter test
flutter build apk --release
```

### Functions

```bash
cd functions
npm run deploy
npm run logs
```

### Admin panel

```bash
cd admin_panel
npm run lint
npm run build
```

## 6) Troubleshooting

### `flutter: command not found`

Install Flutter and ensure it is on your shell `PATH`.

### `next: not found` in admin panel

Run `npm install` in `admin_panel/` before running lint/dev/build scripts.

### Notification/presence not working

Verify:

- `.env` values are present and correct
- Firebase/Supabase projects are configured
- user token/user records exist in expected collections/tables
- Cloud Run URL in `USER_STATUS_SOCKET_URL` is reachable

## 7) Contribution Workflow

1. Create a branch from your fork.
2. Keep changes focused by area (UI, service, docs, scripts).
3. Run relevant checks for the files you changed.
4. Open a PR with summary + validation notes.
