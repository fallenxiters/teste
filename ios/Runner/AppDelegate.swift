import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  var obfuscatingView: UIView?  // Camada de proteção

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    let antiGravacaoChannel = FlutterMethodChannel(name: "com.yourapp/antiGravacao", binaryMessenger: controller.binaryMessenger)

    antiGravacaoChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "activateAntiGravacao" {
        self?.startObserving()  // Ativar a detecção de captura de tela
        result(nil)
      } else if call.method == "deactivateAntiGravacao" {
        self?.stopObserving()  // Desativar a detecção de captura de tela
        result(nil)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func startObserving() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleAppScreenshotNotification), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
  }

  func stopObserving() {
    NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    removeObfuscatingView()
  }

  @objc func handleAppScreenshotNotification() {
    let blackScreen = UIView(frame: self.window?.frame ?? CGRect.zero)
    blackScreen.backgroundColor = .black
    blackScreen.tag = 999  // Tag para facilitar a remoção
    self.window?.addSubview(blackScreen)

    UIView.animate(withDuration: 0.3, animations: {
      blackScreen.alpha = 0
    }) { _ in
      blackScreen.removeFromSuperview()
    }
  }

  func removeObfuscatingView() {
    if let obfuscatingView = self.window?.viewWithTag(999) {
      obfuscatingView.removeFromSuperview()
    }
  }
}
