import Cocoa
import FlutterMacOS

public class FlutterNewBadgerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_new_badger", binaryMessenger: registrar.messenger)
        let instance = FlutterNewBadgerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setBadge":
            setBadge(call: call, result: result)
        case "removeBadge":
            removeBadge(result: result)
        case "getBadge":
            getBadge(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setBadge(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let count = arguments["count"] as? Int else {
            result(FlutterError(
                code: "BAD_ARGS",
                message: "Invalid arguments for setting badge count. Expected a dictionary with an integer 'count'.",
                details: nil
            ))
            return
        }

        DispatchQueue.main.async {
            if count > 0 {
                NSApplication.shared.dockTile.badgeLabel = "\(count)"
            } else {
                NSApplication.shared.dockTile.badgeLabel = nil
            }
            result(nil)
        }
    }

    private func removeBadge(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            NSApplication.shared.dockTile.badgeLabel = nil
            result(nil)
        }
    }

    private func getBadge(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let badgeLabel = NSApplication.shared.dockTile.badgeLabel,
               let badgeCount = Int(badgeLabel) {
                result(badgeCount)
            } else {
                result(0) // Return 0 if no badge is set
            }
        }
    }
}
