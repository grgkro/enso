import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    BTAppContextSwitcher.setReturnURLScheme("com.example.ensobox.payments") // https://pub.dev/packages/flutter_braintree and https://developer.paypal.com/braintree/docs/guides/paypal/client-side/ios/v4
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
