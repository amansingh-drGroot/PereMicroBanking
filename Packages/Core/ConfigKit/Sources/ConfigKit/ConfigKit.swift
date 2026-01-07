//
//  ConfigKit.swift
//  ConfigKit
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseRemoteConfig

public class ConfigKit {
    public static let shared = ConfigKit()
    
    private var isConfigured = false
    private var remoteConfig: RemoteConfig?
    
    private init() {}
    
    /// Configures Firebase and other app-wide configurations
    /// This should be called once at app launch
    /// Configures: Analytics, Crashlytics, and Remote Config
    public func configure() {
        guard !isConfigured else {
            print("ConfigKit: Already configured")
            return
        }
        
        // Firebase Core configuration
        // Note: GoogleService-Info.plist should be added to the main app target
        FirebaseApp.configure()
        
        // Configure Remote Config
        let config = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // Fetch at most once per hour
        config.configSettings = settings
        self.remoteConfig = config
        
        // Set default values for Remote Config (if needed)
        // config.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        // Fetch Remote Config values
        config.fetch { (status, error) in
            if status == .success {
                config.activate { (changed, error) in
                    if let error = error {
                        print("ConfigKit: Remote Config activation error: \(error.localizedDescription)")
                    } else {
                        print("ConfigKit: Remote Config activated")
                    }
                }
            } else {
                print("ConfigKit: Remote Config fetch error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        // Crashlytics is automatically configured with FirebaseApp.configure()
        // Analytics is automatically configured with FirebaseApp.configure()
        
        isConfigured = true
        print("ConfigKit: Configuration completed (Analytics, Crashlytics, Remote Config)")
    }
    
    /// Returns whether the configuration has been completed
    public var configured: Bool {
        return isConfigured
    }
    
    /// Get Remote Config instance
    public func getRemoteConfig() -> RemoteConfig? {
        return remoteConfig
    }
    
    /// Get a Remote Config value
    public func getConfigValue(forKey key: String) -> RemoteConfigValue? {
        return remoteConfig?.configValue(forKey: key)
    }
}

