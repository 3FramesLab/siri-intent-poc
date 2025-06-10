// ios/Runner/AppDelegate.swift - Enhanced with automatic setup
import UIKit
import Flutter
import Intents
import IntentsUI

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var intentRoute: String?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        
        let shortcutsChannel = FlutterMethodChannel(
            name: "siri_shortcuts",
            binaryMessenger: controller.binaryMessenger
        )
        
        shortcutsChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "checkSiriStatus":
                let status = self?.checkSiriStatus() ?? ["available": false, "authorized": false]
                result(status)
                
            case "requestSiriAuthorization":
                self?.requestSiriAuthorization { authorized in
                    result(authorized)
                }
                
            case "openAppSettings":
                let opened = self?.openAppSettings() ?? false
                result(opened)
                
            case "presentAddToSiriSheet":
                if let args = call.arguments as? [String: Any],
                   let identifier = args["identifier"] as? String {
                    self?.presentAddToSiriSheet(identifier: identifier) { success in
                        result(success)
                    }
                } else {
                    result(false)
                }
                
            case "getVoiceShortcuts":
                self?.getVoiceShortcuts { shortcuts in
                    result(shortcuts)
                }
                
            case "donateShortcut":
                if let args = call.arguments as? [String: Any] {
                    self?.donateShortcut(args: args)
                }
                result("Shortcut donated")
                
            case "getIntentRoute":
                result(self?.intentRoute)
                self?.intentRoute = nil
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Siri Status Checking
    private func checkSiriStatus() -> [String: Any] {
        var status: [String: Any] = [:]
        
        // Check if Siri is available
        status["available"] = INPreferences.siriAuthorizationStatus() != .notDetermined
        
        // Check authorization status
        let authStatus = INPreferences.siriAuthorizationStatus()
        status["authorized"] = authStatus == .authorized
        status["authorizationStatus"] = authStatus.rawValue
        
        return status
    }
    
    // MARK: - Request Siri Authorization
    private func requestSiriAuthorization(completion: @escaping (Bool) -> Void) {
        INPreferences.requestSiriAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    // MARK: - Open App Settings
    private func openAppSettings() -> Bool {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
            return true
        }
        return false
    }
    
    // MARK: - Present Add to Siri Sheet
    private func presentAddToSiriSheet(identifier: String, completion: @escaping (Bool) -> Void) {
        // First, create the shortcut
        let userActivity = createUserActivity(for: identifier)
        guard let userActivity = userActivity else {
            completion(false)
            return
        }
        
        let shortcut = INShortcut(userActivity: userActivity)
        
        // Present the Add to Siri view controller
        if #available(iOS 12.0, *) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = AddToSiriDelegate(completion: completion)
            
            DispatchQueue.main.async {
                if let rootViewController = self.window?.rootViewController {
                    rootViewController.present(viewController, animated: true, completion: nil)
                }
            }
        } else {
            completion(false)
        }
    }
    
    // MARK: - Get Voice Shortcuts
    private func getVoiceShortcuts(completion: @escaping ([[String: Any]]) -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { shortcuts, error in
            var result: [[String: Any]] = []
            
            if let shortcuts = shortcuts {
                for shortcut in shortcuts {
                    var shortcutInfo: [String: Any] = [:]
                    shortcutInfo["identifier"] = shortcut.identifier.uuidString
                    shortcutInfo["invocationPhrase"] = shortcut.invocationPhrase
                    
                    if let activityType = shortcut.shortcut.userActivity?.activityType {
                        shortcutInfo["activityType"] = activityType
                    }
                    
                    result.append(shortcutInfo)
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func createUserActivity(for identifier: String) -> NSUserActivity? {
        var title: String
        var route: String
        
        switch identifier {
        case "open_comdata":
            title = "Open Comdata"
            route = "/comdata"
        case "open_notifications":
            title = "Open Notifications"
            route = "/notifications"
        default:
            return nil
        }
        
        let userActivity = NSUserActivity(activityType: identifier)
        userActivity.title = title
        userActivity.userInfo = ["route": route]
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.keywords = Set([title.lowercased(), identifier])
        
        if #available(iOS 14.0, *) {
            userActivity.suggestedInvocationPhrase = title
        }
        
        return userActivity
    }
    
    private func donateShortcut(args: [String: Any]) {
        guard let identifier = args["identifier"] as? String,
              let title = args["title"] as? String,
              let route = args["route"] as? String else {
            return
        }
        
        let userActivity = NSUserActivity(activityType: identifier)
        userActivity.title = title
        userActivity.userInfo = ["route": route]
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.keywords = Set([title.lowercased(), identifier])
        
        if #available(iOS 14.0, *) {
            userActivity.suggestedInvocationPhrase = title
        }
        
        userActivity.becomeCurrent()
        
        let shortcut = INShortcut(userActivity: userActivity)
        INVoiceShortcutCenter.shared.setShortcutSuggestions([shortcut])
    }
    
    // MARK: - Handle Incoming Intents
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        
        switch userActivity.activityType {
        case "open_comdata":
            intentRoute = "/comdata"
        case "open_notifications":
            intentRoute = "/notifications"
        default:
            if let route = userActivity.userInfo?["route"] as? String {
                intentRoute = route
            }
        }
        
        return true
    }
}

// MARK: - Add to Siri Delegate
@available(iOS 12.0, *)
class AddToSiriDelegate: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    private let completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    func addVoiceShortcutViewController(
        _ controller: INUIAddVoiceShortcutViewController,
        didFinishWith voiceShortcut: INVoiceShortcut?,
        error: Error?
    ) {
        controller.dismiss(animated: true) {
            self.completion(voiceShortcut != nil)
        }
    }
    
    func addVoiceShortcutViewControllerDidCancel(
        _ controller: INUIAddVoiceShortcutViewController
    ) {
        controller.dismiss(animated: true) {
            self.completion(false)
        }
    }
}