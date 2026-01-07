//
//  AuthenticationRootView.swift
//  PereMicroBanking
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI
import CoreAuth

struct AuthenticationRootView: View {
    @State private var showSignup = false
    @State private var isAuthenticated = false
    private let authService = AuthService.shared
    
    var body: some View {
        Group {
            if isAuthenticated {
                ContentView()
            } else {
                if showSignup {
                    SignupView()
                } else {
                    VStack(spacing: 16) {
                        LoginView()
                        
                        Button("Don't have an account? Sign Up") {
                            showSignup = true
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            checkAuthentication()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("UserDidLogin"))) { _ in
            checkAuthentication()
        }
    }
    
    private func checkAuthentication() {
        isAuthenticated = authService.getCurrentUser() != nil
    }
}

