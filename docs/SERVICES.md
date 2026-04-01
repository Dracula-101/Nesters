# Services Reference

This document summarizes service responsibilities and runtime behavior for the non-UI parts of Nesters.

## Firebase Cloud Functions (`/functions`)

### Runtime

- Node.js 18 (from `functions/package.json`)
- Dependencies: `firebase-admin`, `firebase-functions`

### Main Exports (from `functions/index.js`)

### HTTPS-triggered functions

- `testNotification`
- `testMessageNotification`
- `sendAcceptNotification`
- `testMessage`
- `testRequest`

These are utility/testing-style endpoints in the current codebase and can also support app-integrated flows (`sendAcceptNotification`).

### Firestore-triggered functions

- `sendNotification`
  - Trigger: `chats/{chatId}/messages/{messageId}` document creation
  - Sends chat message notifications to recipient
- `sendRequestNotification`
  - Trigger: `users/{userId}/receivedRequests/{requestId}` document creation
  - Sends request notifications

### Local Commands

```bash
cd functions
npm install
npm run serve   # emulator
npm run deploy  # deploy functions
npm run logs    # function logs
```

## Cloud Run Presence Service (`/cloud_run`)

### Runtime

- Node.js >=16
- Dependencies: `express`, `socket.io`, `firebase-admin`, `dotenv`

### Behavior

- Starts HTTP server and Socket.IO listener (default port `8080` unless `PORT` is set).
- Reads user identifier from socket header `userid`.
- Writes user presence updates to Firebase Realtime Database path `user_status/{userId}`.
- Sets statuses such as Online/Offline and lastSeen timestamps.

### Required Environment Variables

- `FIREBASE_DATABASE_URL`
- `BASE64_SERVICE_ACCOUNT`
- `PORT` (optional)

### Local Command

```bash
cd cloud_run
npm install
npm start
```

## Admin Panel (`/admin_panel`)

### Runtime

- Next.js 15 + React 19
- TypeScript support enabled
- Tailwind CSS configured

### Current Scope

The current code in `admin_panel/src/app` primarily demonstrates UI components and app scaffold behavior. It should be treated as an adjacent web workspace in this repository.

### Local Commands

```bash
cd admin_panel
npm install
npm run dev
npm run lint
```

## Notes on Service Coupling

- Mobile app depends on both Firebase and Supabase configurations.
- Functions depend on Firestore user/chat data consistency and valid FCM tokens.
- Presence service depends on client socket connection lifecycle and authenticated/valid `userid` header values.
