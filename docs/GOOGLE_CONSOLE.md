# Google Console Cloud for Nesters

Nesters uses Google Maps and Places API to provide location-based services and features.
- **Google Maps** is used to display maps and locations in the app.
- **Google Places** API is used to search for places and locations.

## Setup

- After the Firebase Setup, go to the [Google Cloud Console](https://console.cloud.google.com/).
- Navigate to the **APIs & Services** section.
- Enable the following APIs:
    - Maps SDK for Android
    - Maps SDK for iOS
    - Places API
- Navigate to the **Credentials** section and create a new API key.   
- Create new  Google Maps `Android` API keys for Debug and Release and add them to the `/android/google-maps.properties` file.

    ```properties
    GOOGLE_MAPS_DEBUG_API_KEY=<your-debug-api-key>
    GOOGLE_MAPS_RELEASE_API_KEY=<your-release-api-key>
    ```
- Create new Google maps `iOS` API keys and add them to the `/ios/Runner/AppDelegate.swift` file.

    ```swift
    @UIApplicationMain
    @objc class AppDelegate: FlutterAppDelegate {
        override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        GMSServices.provideAPIKey("<your-ios-api-key>")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }
    ```

- Create new Places API keys for Android and iOS and add them to the `env` file:
    ```env
    GOOGLE_ANDROID_PLACES_API_KEY=<your-android-api-key>
    GOOGLE_IOS_PLACES_API_KEY=<your-ios-api-key>
    ```
   