# Activity 14 - Firebase Cloud Messaging

Eziz Bagshiyev | CSC 4360 | November 10, 2026

## Verified result

The Android app builds, installs, and passes all four required live Firebase tests on the Pixel 7 Android 17 emulator. Source analysis found no issues. See the reflection and four labeled evidence composites.

| Test | Observed handler | Result |
| --- | --- | --- |
| T1: foreground | onMessage, count 1 | Event title and promo image applied |
| T2: background notification tap | onMessageOpenedApp, count 2 | Event content displayed |
| T3: notification cold start | getInitialMessage, count 1 on new launch | Event content displayed |
| T4: invalid asset | onMessage, count 2 | Rejection diagnostic; prior title/image preserved |

Repository: https://github.com/ezizbagshiyev/mad-activity14-fcm

## Run

Use JDK 21 for Gradle. Java and Kotlin bytecode targets are both explicitly 17. Install Android SDK/build tools 36 and use an Android target with Google Play services.

```powershell
flutter config --jdk-dir="C:\Program Files\Java\jdk-21"
flutter pub get
flutter analyze
flutter run -d emulator-5554
```

Adjust the JDK path and device ID for your computer. The tested source uses Firebase Core 4.15.2 and Messaging 16.7.1, recorded in pubspec.lock.

## Submit

1. Repository link above.
2. Bagshiyev_Eziz_Activity14_Reflection.txt (three responses, context, payload, and T1-T4 results).
3. Four labeled evidence/T1_evidence.png through T4_evidence.png composites. The archive includes originals as well.

Nothing was submitted to the LMS automatically.

## Configuration

The existing Android identifier `edu.gsu.eziz.incl12b` intentionally matches its Firebase registration in project `eziz-campus-supply-2026-ae07e`. It can replace the earlier Campus Supply Desk app if installed with the same signing key. Register/configure another Android identifier if both apps must coexist. Firebase client configuration is included; no private service-account key or device token is included.

`lib/fcm_service.dart` owns foreground/open/token listeners, retrieves the initial message, and cancels subscriptions. `lib/main.dart` awaits Firebase startup, registers the non-UI background callback, guards widget lifetime, and validates payload values against bundled assets. Android library modules finalize compile SDK/build tools 36 consistently. Local images are original assets.

T3 used removal from recents, then an actual notification tap. These results cover one emulator and do not guarantee delivery under all device or platform policies. Separate data-only background processing and iOS are outside this verified run.

Based on the instructor's [Activity 14 implementation](https://codd.cs.gsu.edu/~lhenry23/mad/ica/act14/v2/implementation.html), setup, and testing guides. ChatGPT assisted with code, testing, and documentation.

## Public configuration and submitted evidence

The public Firebase configuration uses YOUR_FIREBASE_API_KEY placeholders. Restore your own local Firebase configuration or run FlutterFire configuration before running a clone. Do not commit the actual key. The four screenshot composites and original captures are supplied in the private submission ZIP; they have not been published to this repository.
