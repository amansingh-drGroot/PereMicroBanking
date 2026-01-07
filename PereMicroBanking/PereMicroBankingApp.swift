//
//  PereMicroBankingApp.swift
//  PereMicroBanking
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI
import FirebaseCore
import ConfigKit
import CoreAuth

@main
struct PereMicroBankingApp: App {
    init() {
        // Configure Firebase and app-wide settings
        ConfigKit.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationRootView()
        }
    }
}
