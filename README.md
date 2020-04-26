# leancloud_official_plugin

An official flutter plugin for [LeanCloud](https://www.leancloud.cn) real-time message service based on [LeanCloud-Swift-SDK](https://github.com/leancloud/swift-sdk) and [LeanCloud-Java-SDK](https://github.com/leancloud/java-unified-sdk).

## Flutter Getting Started

This project is a starting point for a Flutter [plug-in package](https://flutter.dev/docs/development/packages-and-plugins),
a specialized package that includes platform-specific implementation code for Android and iOS.

For help getting started with Flutter, 
view [online documentation](https://flutter.dev/docs), 
which offers tutorials, samples, guidance on mobile development, and a full API reference.

## Usage

### Adding dependency

1. Following this [document](https://flutter.dev/docs/development/packages-and-plugins/using-packages) to add **leancloud_official_plugin** to your app, like this:

    ```
    dependencies:
      leancloud_official_plugin: '>=x.y.z <(x+1).0.0'    # Recommend using up-to-next-major policy.
    ```

2. Using [Gradle](https://gradle.org/) and [CocoaPods](https://cocoapods.org) to add platform-specific dependencies.

    * Using *CocoaPods* in *terminal*
      * do `$ cd ios/` 
      * then `$ pod update` or `$ pod install --repo-update`
    * *Gradle*
      * TODO

### Initialization

1. import `package:leancloud_official_plugin/leancloud_plugin.dart` in `lib/main.dart` of your project, like this:
    ```dart
    import 'package:leancloud_official_plugin/leancloud_plugin.dart';
    ```

2. import `cn.leancloud.AVOSCloud`, `cn.leancloud.AVLogger` and `cn.leancloud.im.AVIMOptions` in `YourApplication.java` of your project, then set up ***ID***, ***Key*** and ***URL***, like this:
    ```java
    import io.flutter.app.FlutterApplication;
    import cn.leancloud.AVOSCloud;
    import cn.leancloud.AVLogger;
    import cn.leancloud.im.AVIMOptions;

    public class YourApplication extends FlutterApplication {
      @Override
      public void onCreate() {
        super.onCreate();
        AVIMOptions.getGlobalOptions().setUnreadNotificationEnabled(true);
        AVOSCloud.setLogLevel(AVLogger.Level.DEBUG);
        AVOSCloud.initialize(this, YOUR_LC_APP_ID, YOUR_LC_APP_KEY, YOUR_LC_SERVER_URL);
      }
    }
    ```

3. import `LeanCloud` in `AppDelegate.swift` of your project, then set up ***ID***, ***Key*** and ***URL***, like this:
    ```swift
    import Flutter
    import LeanCloud

    @UIApplicationMain
    @objc class AppDelegate: FlutterAppDelegate {
        override func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            do {
                LCApplication.logLevel = .all
                try LCApplication.default.set(
                    id: YOUR_LC_APP_ID,
                    key: YOUR_LC_APP_KEY,
                    serverURL: YOUR_LC_SERVER_URL)
                GeneratedPluginRegistrant.register(with: self)
                return super.application(application, didFinishLaunchingWithOptions: launchOptions)
            } catch {
                fatalError("\(error)")
            }
        }
    }
    ```

### Push setup (optional)

Due to different push service in iOS and Android, the setup-code should be wrote in native platform. 
it's optional, so if you no need of push service, you can ignore this section.

* iOS

    ```swift
    import Flutter
    import LeanCloud
    import UserNotifications

    @UIApplicationMain
    @objc class AppDelegate: FlutterAppDelegate {
        override func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            do {
                LCApplication.logLevel = .all
                try LCApplication.default.set(
                    id: YOUR_LC_APP_ID,
                    key: YOUR_LC_APP_KEY,
                    serverURL: YOUR_LC_SERVER_URL)
                GeneratedPluginRegistrant.register(with: self)
                /*
                register APNs to access token, like this:
                */ 
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    switch settings.authorizationStatus {
                    case .authorized:
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    case .notDetermined:
                        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                            if granted {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        }
                    default:
                        break
                    }
                }
                return super.application(application, didFinishLaunchingWithOptions: launchOptions)
            } catch {
                fatalError("\(error)")
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) 
        /* 
        set APNs deviceToken and Team ID.
        */
        LCApplication.default.currentInstallation
            .set(
                deviceToken: deviceToken,
                apnsTeamId: YOUR_APNS_TEAM_ID)
        /* 
        add `client-id` to `channels`, you can use flutter platform channels to pass `client-id` from flutter to native platform.

        flutter platform channels reference: 
            https://flutter.dev/docs/development/platform-integration/platform-channels
        */
        try LCApplication.default.currentInstallation
            .append(
                "channels",
                element: YOUR_CLIENT_ID,
                unique: true)
        /* 
        save to LeanCloud.
        */
        LCApplication.default.currentInstallation.save { (result) in
            switch result {
            case .success:
                break
            case .failure(error: let error):
                print(error)
            }
        }
    }
    ```

* Android

    ```java
    TODO
    ```

## Sample Code

After initialization, you can write some sample code and run it to check whether initializing success, like this:

### Open

```dart
// new an IM client
Client client = Client(id: CLIENT_ID);
// open it
await client.open();
```

### Query Conversations

```dart
// the ID of the conversation instance list
List<String> objectIDs = [...];
// new query from an opened client
ConversationQuery query = client.conversationQuery();
// set query condition
Map whereMap = {
  'objectId': {
    '\$in': objectIDs,
  }
};
query.whereString = jsonEncode(whereMap);
query.limit = objectIDs.length;
// do the query
List<Conversation> conversations = await query.find();
```
