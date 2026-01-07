//
//  LoginViewModel.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation
import Combine

@MainActor
public class LoginViewModel: ObservableObject {
    @Published public var userID: String = ""
    @Published public var password: String = ""
    @Published public var pin: String = ""
    @Published public var otp: String = ""
    @Published public var authState: AuthState = .unauthenticated
    @Published public var requiresPIN: Bool = false
    @Published public var requiresOTP: Bool = false
    @Published public var errorMessage: String?
    @Published public var isLoading: Bool = false
    
    private let authService: AuthServiceProtocol
    private let otpService: OTPServiceProtocol
    private let pinService: PINServiceProtocol
    
    public init(
        authService: AuthServiceProtocol = AuthService.shared,
        otpService: OTPServiceProtocol = OTPService.shared,
        pinService: PINServiceProtocol = PINService.shared
    ) {
        self.authService = authService
        self.otpService = otpService
        self.pinService = pinService
    }
    
    /// Performs login with current credentials
    public func login() async {
        guard !userID.isEmpty && !password.isEmpty else {
            errorMessage = "User ID and Password are required"
            return
        }
        
        isLoading = true
        authState = .authenticating
        errorMessage = nil
        
        do {
            let credentials = LoginCredentials(
                userID: userID,
                password: password,
                pin: pin.isEmpty ? nil : pin,
                otp: otp.isEmpty ? nil : otp
            )
            
            let result = try await authService.login(with: credentials)
            
            if result.requiresOTP && otp.isEmpty {
                requiresOTP = true
                authState = .unauthenticated
                // Send OTP
                try await sendOTP()
            } else if result.requiresPIN && pin.isEmpty {
                requiresPIN = true
                authState = .unauthenticated
            } else {
                authState = .authenticated
                // Post notification to trigger navigation to ContentView
                NotificationCenter.default.post(name: NSNotification.Name("UserDidLogin"), object: nil)
            }
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            authState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Sends OTP to registered mobile number
    public func sendOTP() async {
        do {
            // TODO: Get mobile number from user profile or credentials
            // For now, using a placeholder
            let mobileNumber = "" // This should come from user's registered mobile
            try await otpService.sendOTP(to: mobileNumber)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Resets the login form
    public func reset() {
        userID = ""
        password = ""
        pin = ""
        otp = ""
        requiresPIN = false
        requiresOTP = false
        errorMessage = nil
        authState = .unauthenticated
    }
    
    // MARK: - Private Helpers
    
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .otpRequired:
            requiresOTP = true
            authState = .unauthenticated
            Task {
                await sendOTP()
            }
        case .pinRequired:
            requiresPIN = true
            authState = .unauthenticated
        default:
            authState = .error(error.localizedDescription ?? "Unknown error")
            errorMessage = error.localizedDescription
        }
    }
}

