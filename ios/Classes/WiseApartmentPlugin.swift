import Flutter
import UIKit

public class WiseApartmentPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "wise_apartment/methods", binaryMessenger: registrar.messenger())
    let instance = WiseApartmentPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getDeviceInfo":
      var info: [String: Any] = [:]
      info["manufacturer"] = "Apple"
      info["model"] = UIDevice.current.model
      info["name"] = UIDevice.current.name
      info["systemName"] = UIDevice.current.systemName
      info["release"] = UIDevice.current.systemVersion
      result(info)
    case "getAndroidBuildConfig":
      result(nil)
    case "initBleClient", "startScan", "openLock", "disconnect":
      result(FlutterError(code: "UNAVAILABLE", message: "Not implemented on iOS", details: nil))
    case "clearSdkState":
       result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
