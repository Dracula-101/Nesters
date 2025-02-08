# Firebase Setup for Nesters

Nesters uses Firebase for its chat service. 
- **Firebase Firestore** is used to store chat rooms, messages and user details.
- **Firebase Functions** are used to send push notifications to users.
- **Firebase Storage** is used to store chat images and files.
- **Firebase Realtime DB** is used to store the user status (Online, Offline).
- **Firebase Cloud Messaging** is used to send push notifications to users.
- **Firebase Crashlytics** is used to monitor app crashes.
- **Firebase Analytics** is used to monitor user activity.


## Initial Setup

- Create a Firebase project from the [Firebase Console](https://console.firebase.google.com/).
- Add an Android app and IOS app to the project and make sure to add the following packages name and bundle id for Android and IOS respectively.
    - Android: `com.app.nesters`
    - IOS: `com.app.nesters.ios`
- Download the `google-services.json` file and `GoogleService-Info.plist` file for Android and IOS respectively.
- For Android: Add the `google-services.json` file to the `android/app` directory.
- For iOS: Add the `GoogleService-Info.plist` file to the `ios/Runner` directory.
- Enable Firestore Database and Firebase Functions for the project.
- *Optional*: Add Crashlytics, Analytics etc. to the firebase project.

## Firebase Firestore

- Create the following collections in Firestore:
    - `chats`: To store chat rooms and their info.
    - `users`: To store user details and their FCM token.
    - `devices`: To store device details for analytics.

- Add the following rules to the Firestore Rules:
    ```js
    rules_version = '1';
    service cloud.firestore {
        match /databases/{database}/documents {
            // Allow read and write access to all
            match /{document=**} {
            allow read, write: if true
            }
        }
    }
    ```

## Firebase Functions

- Make sure to enable billing (*switch to Blaze plan*) for the Firebase project to use Firebase Functions.

- Create a new folder named `chats` in the root directory of the Firebase Storage.

- Add rules to the Firebase Storage to allow read and write access to the `chats` folder:
    ```js
    rules_version = '1';
    service firebase.storage {
        match /b/{bucket}/o {
            match /{allPaths=**} {
            allow read, write: if true;
            }
        }
    }
    ```

- Add the firebase tools to the project by running the following command:
    ```bash
    npm install -g firebase-tools
    ```
- Login to firebase using the following command:
    ```bash
    firebase login
    ```
- Initialize the firebase project in the root directory of the project by running the following command:
    ```bash
    firebase init
    ```
- Attach the firebase project and select the `Functions` option.

- Deploy the functions by running the following command:
    ```bash
    firebase deploy --only functions
    ```
- After successful deployment, copy the function url to the `.env` file under the key `CLOUD_FUNCTION_URL`.

## Cloud Run Setup

- Add Firebase Realtime DB in the Firebase Console and add the following rules to the Realtime DB:
    ```json
    {
        "rules": {
            ".read": "true",
            ".write": "true"
        }
    }
    ```

- Navigate to the `cloud_run` folder and copy the Firestore url from Firebase Console and Paste to the `secrets.json` file under the key `FIRESTORE_URL`.

- Create a new service account and add the following roles to the service account in the Google Console of your project:
    - Firebase Admin

- Base 64 encode the service account json file and paste it to the `secrets.json` file under the key `BASE64_SERVICE_ACCOUNT`.

-  Run the following command to deploy the Cloud Run service ([Reference](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-nodejs-service)):
    ```bash
    gcloud init
    gcloud config set project <PROJECT-ID>
    gcloud services enable run.googleapis.com cloudbuild.googleapis.com
    ```
- Run the command to deploy the Cloud Run service and allow unauthenticated invocations and replace the <SERVICE_ACCOUNT> with the service account email (*make sure to get the email contents before the @ symbol*):
    ```bash
    gcloud run deploy user-status-socket --source . --allow-unauthenticated --platform=managed --port=8080 --memory=512Mi --max-instances=3 --env-vars-file=secrets.json --service-account=<SERVICE_ACCOUNT>
    ```

- After successful deployment, copy the Cloud Run service URL and paste it to the `.env` file under the key `USER_STATUS_SOCKET_URL`.

    







