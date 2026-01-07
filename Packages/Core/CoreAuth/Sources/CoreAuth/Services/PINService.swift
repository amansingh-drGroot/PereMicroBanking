//
//  PINService.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public protocol PINServiceProtocol {
    func validatePIN(_ pin: String) -> Bool
    func encryptPIN(_ pin: String) -> String?
    func verifyPIN(_ pin: String, against encrypted: String) -> Bool
}

public class PINService: PINServiceProtocol {
    public static let shared = PINService()
    
    private let minPINLength = 4
    private let maxPINLength = 6
    
    private init() {}
    
    /// Validates PIN format
    /// - Parameter pin: PIN to validate
    /// - Returns: true if PIN format is valid
    public func validatePIN(_ pin: String) -> Bool {
        // PIN should be numeric and between 4-6 digits
        guard pin.allSatisfy({ $0.isNumber }),
              pin.count >= minPINLength,
              pin.count <= maxPINLength else {
            return false
        }
        
        // Additional validation: PIN should not be all same digits (e.g., 1111)
        let uniqueDigits = Set(pin)
        guard uniqueDigits.count > 1 else {
            return false
        }
        
        return true
    }
    
    /// Encrypts PIN (placeholder - use proper encryption in production)
    /// - Parameter pin: PIN to encrypt
    /// - Returns: Encrypted PIN string
    public func encryptPIN(_ pin: String) -> String? {
        // TODO: Implement proper encryption (e.g., using Keychain or backend encryption)
        // For now, this is a placeholder
        guard validatePIN(pin) else {
            return nil
        }
        
        // In production, use proper encryption
        return pin.data(using: .utf8)?.base64EncodedString()
    }
    
    /// Verifies PIN against encrypted version
    /// - Parameters:
    ///   - pin: Plain text PIN
    ///   - encrypted: Encrypted PIN
    /// - Returns: true if PIN matches
    public func verifyPIN(_ pin: String, against encrypted: String) -> Bool {
        // TODO: Implement proper decryption and comparison
        guard let decrypted = Data(base64Encoded: encrypted),
              let decryptedString = String(data: decrypted, encoding: .utf8) else {
            return false
        }
        
        return pin == decryptedString
    }
}

