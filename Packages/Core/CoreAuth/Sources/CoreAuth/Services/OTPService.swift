//
//  OTPService.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public protocol OTPServiceProtocol {
    func sendOTP(to mobileNumber: String) async throws
    func verifyOTP(_ otp: String, for mobileNumber: String) async throws -> Bool
}

public class OTPService: OTPServiceProtocol {
    public static let shared = OTPService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    /// Sends OTP to the specified mobile number
    /// - Parameter mobileNumber: Mobile number to send OTP to
    /// - Throws: AuthError if sending fails
    public func sendOTP(to mobileNumber: String) async throws {
        try await sendOTP(to: mobileNumber, purpose: "signup")
    }
    
    /// Sends OTP to the specified mobile number with purpose
    /// - Parameters:
    ///   - mobileNumber: Mobile number to send OTP to
    ///   - purpose: Purpose of OTP (signup/login/password_reset)
    /// - Throws: AuthError if sending fails
    public func sendOTP(to mobileNumber: String, purpose: String) async throws {
        // Validate mobile number format
        guard isValidMobileNumber(mobileNumber) else {
            throw AuthError.invalidInput("Invalid mobile number format")
        }
        
        // Prepare request
        let request = OTPSendRequest(
            contactNumber: mobileNumber,
            purpose: purpose
        )
        
        // Convert to dictionary for API call
        var body: [String: Any] = [
            "contactNumber": request.contactNumber
        ]
        
        if let purpose = request.purpose {
            body["purpose"] = purpose
        }
        
        do {
            // Call API
            let _: OTPSendResponse = try await apiClient.request(
                endpoint: "/auth/otp/send",
                method: "POST",
                body: body,
                requiresAuth: false
            )
            
            // Success - OTP sent
        } catch let error as APIError {
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError
        }
    }
    
    /// Verifies the OTP for the specified mobile number
    /// - Parameters:
    ///   - otp: OTP to verify
    ///   - mobileNumber: Mobile number associated with the OTP
    /// - Returns: true if OTP is valid, false otherwise
    /// - Throws: AuthError if verification fails
    public func verifyOTP(_ otp: String, for mobileNumber: String) async throws -> Bool {
        return try await verifyOTP(otp, for: mobileNumber, purpose: "signup")
    }
    
    /// Verifies the OTP for the specified mobile number with purpose
    /// - Parameters:
    ///   - otp: OTP to verify
    ///   - mobileNumber: Mobile number associated with the OTP
    ///   - purpose: Purpose of OTP verification
    /// - Returns: true if OTP is valid, false otherwise
    /// - Throws: AuthError if verification fails
    private func verifyOTP(_ otp: String, for mobileNumber: String, purpose: String) async throws -> Bool {
        // Prepare request
        let request = OTPVerifyRequest(
            contactNumber: mobileNumber,
            otp: otp,
            purpose: purpose
        )
        
        // Convert to dictionary for API call
        var body: [String: Any] = [
            "contactNumber": request.contactNumber,
            "otp": request.otp
        ]
        
        if let purpose = request.purpose {
            body["purpose"] = purpose
        }
        
        do {
            // Call API
            let response: OTPVerifyResponse = try await apiClient.request(
                endpoint: "/auth/otp/verify",
                method: "POST",
                body: body,
                requiresAuth: false
            )
            
            if response.verified {
                return true
            } else {
                throw AuthError.otpInvalid
            }
            
        } catch let error as APIError {
            throw mapAPIError(error)
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.networkError
        }
    }
    
    // MARK: - Private Helpers
    
    private func isValidMobileNumber(_ number: String) -> Bool {
        // Basic validation - adjust based on your requirements
        let cleaned = number.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        // Check if it's numeric and has reasonable length (10-15 digits)
        return cleaned.allSatisfy { $0.isNumber } && cleaned.count >= 10 && cleaned.count <= 15
    }
    
    private func mapAPIError(_ error: APIError) -> AuthError {
        switch error {
        case .badRequest(let message):
            if message.lowercased().contains("otp") && message.lowercased().contains("invalid") {
                return AuthError.otpInvalid
            }
            if message.lowercased().contains("expired") {
                return AuthError.otpExpired
            }
            return AuthError.invalidInput(message)
        case .rateLimited:
            return AuthError.networkError
        case .networkError(let message):
            return AuthError.networkError
        default:
            return AuthError.networkError
        }
    }
}

