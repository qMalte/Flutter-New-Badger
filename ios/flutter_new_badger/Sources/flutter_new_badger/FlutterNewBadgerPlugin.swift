import Flutter
import UIKit
import UserNotifications

public class FlutterNewBadgerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_new_badger", binaryMessenger: registrar.messenger())
        let instance = FlutterNewBadgerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setBadge":
            if let arguments = call.arguments as? [String: Any], let count = arguments["count"] as? Int {
                setBadgeCount(count: count, result: result)
            } else {
                result(FlutterError(
                    code: "BAD_ARGS",
                    message: "Invalid arguments for setting badge count. Expected a dictionary with an integer 'count'.",
                    details: nil
                ))
            }

        case "removeBadge":
            setBadgeCount(count: 0, result: result)

        case "getBadge":
            getBadgeCount(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setBadgeCount(count: Int, result: @escaping FlutterResult) {
        // Check current notification authorization status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                self.updateBadgeCount(count: count, result: result)
            case .denied:
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "PERMISSION_DENIED",
                        message: "Badge permission denied. Please enable badges in settings.",
                        details: nil
                    ))
                }
            case .notDetermined:
                // Request authorization if not determined
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { granted, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            result(FlutterError(
                                code: "AUTH_ERROR",
                                message: "Notification authorization failed.",
                                details: error.localizedDescription
                            ))
                        }
                        return
                    }

                    if granted {
                        self.updateBadgeCount(count: count, result: result)
                    } else {
                        DispatchQueue.main.async {
                            result(FlutterError(
                                code: "PERMISSION_DENIED",
                                message: "Badge permission denied.",
                                details: nil
                            ))
                        }
                    }
                }
            @unknown default:
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "UNKNOWN_ERROR",
                        message: "Unknown authorization status.",
                        details: nil
                    ))
                }
            }
        }
    }

    private func updateBadgeCount(count: Int, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
            result(nil)
        }
    }

    private func getBadgeCount(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
            result(badgeNumber)
        }
    }
}
