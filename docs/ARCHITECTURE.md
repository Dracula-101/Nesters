# Nesters Architecture

This document describes the architecture of the Nesters repository based on the current codebase.

## 1) System Overview

Nesters is organized as a multi-service system:

- **Flutter mobile app** (`/lib`) for end-user interaction.
- **Firebase Cloud Functions** (`/functions`) for notification workflows.
- **Cloud Run Socket.IO service** (`/cloud_run`) for real-time user presence.
- **Supabase** for core domain data (users/listings in project docs and repository usage).
- **Firebase Firestore + Realtime Database + FCM** for chat/request events, presence, and notifications.

## 2) Main Components

### 2.1 Flutter App

Key entry points:

- `lib/main.dart`
  - Initializes Firebase
  - Loads app secrets and initializes Supabase
  - Sets Crashlytics handlers
  - Configures background messaging handler
- `lib/locators.dart`
  - Registers repositories/services in `GetIt`
- `lib/app/routes/app_routes.dart`
  - Centralized routing with `go_router`

High-level internal organization:

- `lib/features/` — feature modules (auth, home, marketplace, sublet, apartment, user, settings)
- `lib/data/repository/` — data source orchestration and service adapters
- `lib/domain/models/` — domain entities

The mobile app uses:

- **BLoC** for state management
- **Repository pattern** for data access and abstraction
- **GetIt** for dependency injection

### 2.2 Firebase Functions

Location: `functions/index.js`

Responsibilities include:

- HTTP test/helper endpoints for sending notifications and creating test messages/requests
- Firestore triggers:
  - `sendNotification` on new chat messages
  - `sendRequestNotification` on new received requests

These functions use `firebase-admin` to read user records and send FCM notifications.

### 2.3 Cloud Run User-Status Service

Location: `cloud_run/index.js`

Responsibilities:

- Accept Socket.IO client connections
- Identify user from socket headers (`userid`)
- Mark users online/offline in Firebase Realtime Database (`user_status`)
- Track last-seen timestamps

This service bridges app lifecycle and real-time presence state.

## 3) Data and Integration Boundaries

### 3.1 Supabase

Used by the Flutter app for primary domain entities and authentication-related flows through repository implementations (for example, sublet/apartment/marketplace repositories and auth repository).

### 3.2 Firebase Firestore

Used for chat/request-related data and notification triggering workflows.

### 3.3 Firebase Realtime Database

Used by Cloud Run service for online/offline user presence updates.

### 3.4 Cloudinary

Used for media/image upload flows configured from `.env` values.

## 4) Request/Data Flows

### 4.1 App Startup Flow

1. `main()` in `lib/main.dart` initializes Firebase.
2. App secrets are loaded from `.env`.
3. Supabase is initialized.
4. Service locator registration occurs via `setupLocator(...)`.
5. App launches with `RootApp` and route graph.

### 4.2 Chat Notification Flow

1. User sends message in app.
2. Chat message is written to Firestore (`chats/{chatId}/messages/{messageId}`).
3. Firestore trigger `sendNotification` executes in `functions/index.js`.
4. Function reads user docs/tokens and sends FCM message.
5. App receives notification; local notification handling is performed in app repositories.

### 4.3 Presence Flow

1. App connects to socket endpoint using configured URL.
2. Cloud Run service validates socket header and marks user online.
3. App lifecycle/status events trigger socket `update` events.
4. Cloud Run writes online/offline and last seen into Realtime DB.

## 5) Architectural Characteristics

- **Feature-first Flutter structure** improves modularity.
- **Repository abstraction** isolates network/storage implementations from UI layer.
- **Event-driven backend** (Firestore triggers + Socket.IO) supports reactive behavior.
- **Multi-provider backend** (Supabase + Firebase) separates domain data and real-time/notification concerns.

## 6) Tradeoffs and Operational Notes

- Cross-service dependencies require careful environment configuration (`.env`, Firebase files, maps keys, secrets).
- Presence and notifications rely on external service uptime and valid user tokens.
- CI workflows in `.github/workflows` show release-oriented automation for Android/iOS artifacts.

## 7) Related Documents

- [SERVICES.md](./SERVICES.md)
- [DEVELOPMENT.md](./DEVELOPMENT.md)
- [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
- [GOOGLE_CONSOLE.md](./GOOGLE_CONSOLE.md)
