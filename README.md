# Nesters

Nesters is a multi-service project centered on a Flutter mobile app for finding roommates and housing options, with supporting backend services for chat notifications and user presence.

## Overview

Nesters helps users discover roommates and housing-related listings in one app:

- **Who it is for:** people looking for roommates or housing options, and users posting housing/marketplace listings.
- **Problem it solves:** combines roommate discovery, listing workflows, messaging, and request handling into a single mobile experience.
- **Primary use cases:**
  - browse and post **sublets**
  - browse and post **apartments**
  - browse and post **marketplace** items
  - connect with users through **chat** and **requests**

The repository also includes:

- a Firebase Cloud Functions service for push-notification flows
- a Node.js Cloud Run socket service for online/offline user status
- an admin_panel (Next.js) app scaffold/component playground
- scripts for seed-data generation and ingestion

## Tech Stack

### Mobile application (`/`)

- **Language:** Dart (SDK `>=3.2.0 <4.0.0`)
- **Framework:** Flutter
- **State management:** `bloc`, `flutter_bloc`, `equatable`, `rxdart`
- **Navigation / DI / storage:** `go_router`, `get_it`, `get_storage`, `shared_preferences`, `objectbox`
- **Backend integrations:**
  - Supabase (`supabase_flutter`) for auth/data integration
  - Firebase (`firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_messaging`, `firebase_database`, `firebase_crashlytics`, `firebase_analytics`)
- **Maps / location:** `google_maps_flutter`, `google_places_sdk`, `geolocator`
- **Media / networking:** `http`, `cached_network_image`, `image_picker`, `flutter_image_compress`, `cloudinary`, `socket_io_client`
- **Notifications:** `flutter_local_notifications`

### Firebase Functions (`/functions`)

- **Runtime:** Node.js 18
- **Libraries:** `firebase-functions`, `firebase-admin`
- **Linting:** ESLint (Google style config)

### User status socket service (`/cloud_run`)

- **Runtime:** Node.js (`>=16.0.0`)
- **Libraries:** `express`, `socket.io`, `firebase-admin`, `dotenv`
- Intended for deployment to **Google Cloud Run**.

### Admin panel (`/admin_panel`)

- **Framework:** Next.js 15 (App Router)
- **Language:** TypeScript/JavaScript + React 19
- **Styling:** Tailwind CSS, class-variance-authority, tailwind-merge
- **Auth dependency present:** `next-auth`

### Data generation scripts (`/scripts`)

- **Python scripts:** `pandas`, `geopy`, optional Selenium-based scraping utilities
- **Node.js seed scripts:** `@supabase/supabase-js`, `@faker-js/faker`, `@turf/turf`, etc.

## Features

From the code and routes in `lib/`:

- User onboarding and authentication flows
- Profile setup/editing and roommate visibility controls
- Multi-tab home experience: **Network, Sublet, Apartments, Marketplace**
- Listing workflows for:
  - sublets (list/detail/form)
  - apartments (list/detail/form)
  - marketplace items (list/detail/form/search)
- In-app chat with request flow and unread/request counts
- Favorite posts and user post management
- Push notifications via Firebase Cloud Messaging
- User online/offline presence via socket service
- Crash reporting and analytics integration

## Project Structure

```text
/home/runner/work/Nesters/Nesters
├── lib/                    # Flutter application code
│   ├── app/                # App bootstrap, routing, app shell/blocs
│   ├── features/           # Feature modules (auth, home, sublet, apartment, marketplace, user, settings)
│   ├── data/repository/    # Repository implementations and service integrations
│   ├── domain/models/      # Domain entities/models
│   ├── theme/              # App theming
│   └── utils/              # Shared utilities/widgets/extensions
├── assets/                 # Fonts, images, SVGs, lottie assets
├── android/                # Android Flutter host app + Gradle config
├── ios/                    # iOS Flutter host app + Xcode project
├── functions/              # Firebase Cloud Functions project
├── cloud_run/              # Node.js socket presence service for Cloud Run
├── admin_panel/            # Next.js app scaffold/admin UI playground
├── scripts/                # Seed generation/scraping utilities
├── schema_backups/         # SQL/schema backup files used for Supabase setup
├── docs/                   # Setup documentation and supporting website/media
└── .github/workflows/      # CI/release workflows
```

### Architecture notes

The Flutter app follows a **feature-first modular structure** with repository-based data access and BLoC state management. Routing is centralized with `go_router` in `lib/app/routes/app_routes.dart`.

## Installation and Setup

### Prerequisites

- Flutter SDK (compatible with Dart `>=3.2.0 <4.0.0`)
- Dart SDK (bundled with Flutter)
- Node.js:
  - Node 18 for `/functions`
  - Node >=16 for `/cloud_run`
- Xcode (for iOS builds) and Android toolchain (for Android builds)
- External service accounts/projects as used by code/docs:
  - Firebase
  - Supabase
  - Google Maps / Places APIs
  - Cloudinary

### 1) Clone and install Flutter dependencies

```bash
git clone https://github.com/Dracula-101/Nesters.git
cd Nesters
flutter pub get
```

### 2) Configure environment variables

Create a root `.env` file from `.env.example`:

```bash
cp .env.example .env
```

Populate required keys (from `lib/data/repository/config/app_secrets_repository.dart`):

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_JWT_TOKEN=
GOOGLE_WEB_CLIENT_ID=
GOOGLE_IOS_CLIENT_ID=
USER_STATUS_SOCKET_URL=
CLOUD_FUNCTION_URL=
GOOGLE_ANDROID_PLACES_API_KEY=
GOOGLE_IOS_PLACES_API_KEY=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

### 3) Configure platform/service files

- Firebase config files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Android Google Maps keys in `android/google-maps.properties`
- iOS Google Maps key in `ios/Runner/AppDelegate.swift` (as currently used by code)

See:

- `docs/FIREBASE_SETUP.md`
- `docs/GOOGLE_CONSOLE.md`
- `docs/SUPABASE_SETUP.md`

### 4) Generate ObjectBox code

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running the Project

### Flutter app (development)

```bash
flutter run
```

### Flutter release builds

```bash
flutter build apk --release
flutter build ipa --release
```

### Firebase Functions (local)

```bash
cd functions
npm install
npm run serve
```

### Cloud Run socket service (local)

```bash
cd cloud_run
npm install
npm start
```

### Admin panel (local)

```bash
cd admin_panel
npm install
npm run dev
```

## Usage

### Mobile app flow

After launching the app:

1. Authenticate and complete profile flows.
2. Browse tabs for Network, Sublet, Apartments, and Marketplace.
3. Open details, create/edit your own posts, and save favorites.
4. Send/receive requests and chat with other users.

### Firebase Functions API surface (from `functions/index.js`)

The following HTTPS functions exist in code:

- `testNotification`
- `testMessageNotification`
- `sendAcceptNotification`
- `testMessage`
- `testRequest`

Firestore-triggered functions:

- `sendNotification` on `chats/{chatId}/messages/{messageId}` create
- `sendRequestNotification` on `users/{userId}/receivedRequests/{requestId}` create

> Function deployment URLs and regions depend on your Firebase project configuration.

## Scripts and Commands

### Root / Flutter

- `flutter pub get` — install Dart/Flutter dependencies
- `flutter run` — run app locally
- `dart run build_runner build --delete-conflicting-outputs` — regenerate generated code
- `flutter analyze` — static analysis
- `flutter test` — run Flutter tests (if test files are present)

### `functions/`

- `npm run serve` — start Firebase emulator for functions
- `npm run shell` / `npm start` — functions shell
- `npm run deploy` — deploy functions
- `npm run logs` — fetch function logs

### `cloud_run/`

- `npm start` — start socket service

### `admin_panel/`

- `npm run dev` — run Next.js dev server (HTTPS)
- `npm run dev:http` — run Next.js dev server (HTTP)
- `npm run build` — build Next.js app
- `npm run start` — start production Next.js server
- `npm run lint` — run Next.js linting

### `scripts/seed/`

- `npm start` — run seed script

## Testing

- Flutter test dependency is configured (`flutter_test`) but no `_test.dart` files are currently present in this repository.
- Firebase Functions includes `firebase-functions-test` as a dev dependency, but no test files were found.

Useful commands:

```bash
flutter analyze
flutter test
cd admin_panel && npm run lint
```

## Configuration

Primary runtime configuration is environment-variable driven:

- Root app secrets via `.env` (loaded by `flutter_dotenv`)
- `cloud_run` uses environment variables such as:
  - `FIREBASE_DATABASE_URL`
  - `BASE64_SERVICE_ACCOUNT`
  - `PORT` (default `8080`)
- `scripts/seed/.env.example` includes Supabase keys used by seeding scripts

Additional config files:

- `analysis_options.yaml` (Dart lint config)
- `scripts/config.json` (seed toggles/counts)
- `android/google-maps.properties` (Android map keys)

## Contributing

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-change
   ```
3. Make focused changes.
4. Run relevant checks:
   - `flutter analyze`
   - `flutter test` (when tests exist)
   - `cd admin_panel && npm run lint` (if touching admin panel)
5. Commit with clear messages and open a pull request.

## License

This repository includes an **Apache License 2.0** license file (`LICENSE`).
