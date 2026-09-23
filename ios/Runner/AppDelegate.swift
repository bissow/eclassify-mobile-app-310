import UIKit
import Flutter
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import GoogleMaps
import awesome_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GMSServices.provideAPIKey("YOUR_API_KEY_HERE")

        SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
            SwiftAwesomeNotificationsPlugin.register(
                with: registry.registrar(
                    forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin"
                )!
            )
        }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func didInitializeImplicitFlutterEngine(
        _ engineBridge: FlutterImplicitEngineBridge
    ) {
        GeneratedPluginRegistrant.register(
            with: engineBridge.pluginRegistry
        )
    }
}
