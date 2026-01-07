//
//  AuthError.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public enum AuthError: LocalizedError {
    case invalidCredentials
    case otpRequired
    case pinRequired
    case otpExpired
    case otpInvalid
    case accountNotFound
    case networkError
    case notImplemented
    case invalidInput(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid User ID or Password"
        case .otpRequired:
            return "OTP is required to complete authentication"
        case .pinRequired:
            return "PIN is required to complete authentication"
        case .otpExpired:
            return "OTP has expired. Please request a new one"
        case .otpInvalid:
            return "Invalid OTP. Please try again"
        case .accountNotFound:
            return "Account not found. Please check your details"
        case .networkError:
            return "Network error. Please check your connection"
        case .notImplemented:
            return "This feature is not yet implemented"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        }
    }
}

