//
//  APIRequests.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

// MARK: - Login Request

struct LoginRequest: Encodable {
    let userID: String
    let password: String
    let pin: String?
    let otp: String?
    
    enum CodingKeys: String, CodingKey {
        case userID
        case password
        case pin
        case otp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(password, forKey: .password)
        try container.encodeIfPresent(pin, forKey: .pin)
        try container.encodeIfPresent(otp, forKey: .otp)
    }
}

// MARK: - Login Response

struct LoginResponse: Decodable {
    let userID: String
    let fullName: String?
    let email: String?
    let token: String
    let expiryDate: Date?
    let requiresPIN: Bool?
    let requiresOTP: Bool?
}

// MARK: - Signup Request

struct SignupRequest: Encodable {
    let country: String
    let fullName: String
    let dateOfBirth: Date
    let address: String
    let contactNumber: String
    let email: String
    let userID: String
    let password: String
    let documents: [DocumentRequest]
    let otp: String?
    
    enum CodingKeys: String, CodingKey {
        case country
        case fullName
        case dateOfBirth
        case address
        case contactNumber
        case email
        case userID
        case password
        case documents
        case otp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(country, forKey: .country)
        try container.encode(fullName, forKey: .fullName)
        
        // Encode date as ISO8601 string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: dateOfBirth), forKey: .dateOfBirth)
        
        try container.encode(address, forKey: .address)
        try container.encode(contactNumber, forKey: .contactNumber)
        try container.encode(email, forKey: .email)
        try container.encode(userID, forKey: .userID)
        try container.encode(password, forKey: .password)
        try container.encode(documents, forKey: .documents)
        try container.encodeIfPresent(otp, forKey: .otp)
    }
}

struct DocumentRequest: Encodable {
    let type: String
    let documentNumber: String
    let frontImage: String?
    let backImage: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case documentNumber
        case frontImage
        case backImage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(documentNumber, forKey: .documentNumber)
        try container.encodeIfPresent(frontImage, forKey: .frontImage)
        try container.encodeIfPresent(backImage, forKey: .backImage)
    }
}

// MARK: - Signup Response

struct SignupResponse: Decodable {
    let userID: String
    let token: String
    let expiryDate: Date?
    let message: String?
}

// MARK: - OTP Send Request

struct OTPSendRequest: Encodable {
    let contactNumber: String
    let purpose: String?
    
    enum CodingKeys: String, CodingKey {
        case contactNumber
        case purpose
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contactNumber, forKey: .contactNumber)
        try container.encodeIfPresent(purpose, forKey: .purpose)
    }
}

// MARK: - OTP Send Response

struct OTPSendResponse: Decodable {
    let message: String
    let expiresIn: Int?
    let retryAfter: Int?
}

// MARK: - OTP Verify Request

struct OTPVerifyRequest: Encodable {
    let contactNumber: String
    let otp: String
    let purpose: String?
    
    enum CodingKeys: String, CodingKey {
        case contactNumber
        case otp
        case purpose
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contactNumber, forKey: .contactNumber)
        try container.encode(otp, forKey: .otp)
        try container.encodeIfPresent(purpose, forKey: .purpose)
    }
}

// MARK: - OTP Verify Response

struct OTPVerifyResponse: Decodable {
    let verified: Bool
    let message: String
    let remainingAttempts: Int?
}

// MARK: - Logout Request

struct LogoutRequest: Encodable {
    let logoutAllDevices: Bool?
    
    enum CodingKeys: String, CodingKey {
        case logoutAllDevices
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(logoutAllDevices, forKey: .logoutAllDevices)
    }
}

// MARK: - Logout Response

struct LogoutResponse: Decodable {
    let message: String
}

