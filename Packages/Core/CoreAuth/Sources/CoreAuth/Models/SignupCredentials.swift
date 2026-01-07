//
//  SignupCredentials.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public enum Country: String, CaseIterable, Identifiable {
    case india = "India"
    case australia = "Australia"
    case philippines = "Philippines"
    
    public var id: String { rawValue }
    
    public var flag: String {
        switch self {
        case .india: return "🇮🇳"
        case .australia: return "🇦🇺"
        case .philippines: return "🇵🇭"
        }
    }
}

public enum DocumentType: String, CaseIterable, Identifiable {
    // India
    case aadhaar = "Aadhaar Card"
    case pan = "PAN Card"
    
    // Australia
    case passport = "Passport"
    case drivingLicense = "Driving License"
    case dvs = "DVS (Document Verification Service)"
    
    // Philippines
    case philsys = "PhilSys National ID"
    case nationalID = "National ID"
    
    public var id: String { rawValue }
    
    public var country: Country {
        switch self {
        case .aadhaar, .pan:
            return .india
        case .passport, .drivingLicense, .dvs:
            return .australia
        case .philsys, .nationalID:
            return .philippines
        }
    }
    
    public static func documents(for country: Country) -> [DocumentType] {
        switch country {
        case .india:
            return [.aadhaar, .pan]
        case .australia:
            return [.passport, .drivingLicense, .dvs]
        case .philippines:
            return [.philsys, .nationalID, .passport]
        }
    }
    
    public var isRequired: Bool {
        switch self {
        case .aadhaar, .pan:
            return true // Both required for India
        case .dvs:
            return false // DVS is optional verification service
        case .passport, .drivingLicense, .philsys, .nationalID:
            return true
        }
    }
    
    public var description: String {
        switch self {
        case .aadhaar:
            return "12-digit unique identification number"
        case .pan:
            return "10-character alphanumeric identifier"
        case .passport:
            return "International travel document"
        case .drivingLicense:
            return "Official driving license"
        case .dvs:
            return "Document Verification Service (optional)"
        case .philsys:
            return "Philippine Identification System"
        case .nationalID:
            return "Philippine National ID"
        }
    }
}

public struct DocumentUpload {
    public let type: DocumentType
    public let documentNumber: String
    public let frontImageData: Data?
    public let backImageData: Data?
    public let uploadedAt: Date
    
    public init(
        type: DocumentType,
        documentNumber: String,
        frontImageData: Data?,
        backImageData: Data? = nil,
        uploadedAt: Date = Date()
    ) {
        self.type = type
        self.documentNumber = documentNumber
        self.frontImageData = frontImageData
        self.backImageData = backImageData
        self.uploadedAt = uploadedAt
    }
}

public struct SignupCredentials {
    // Country Selection
    public let country: Country
    
    // Personal Information
    public let fullName: String
    public let dateOfBirth: Date
    public let address: String
    public let contactNumber: String
    public let email: String
    
    // Credentials
    public let userID: String
    public let password: String
    
    // Mandatory Documents (Proof of Identity/Address)
    public let documents: [DocumentUpload]
    
    // OTP Verification
    public var otp: String?
    
    public init(
        country: Country,
        fullName: String,
        dateOfBirth: Date,
        address: String,
        contactNumber: String,
        email: String,
        userID: String,
        password: String,
        documents: [DocumentUpload],
        otp: String? = nil
    ) {
        self.country = country
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.address = address
        self.contactNumber = contactNumber
        self.email = email
        self.userID = userID
        self.password = password
        self.documents = documents
        self.otp = otp
    }
    
    public var isValid: Bool {
        !fullName.isEmpty &&
        !address.isEmpty &&
        !contactNumber.isEmpty &&
        !email.isEmpty &&
        !userID.isEmpty &&
        !password.isEmpty &&
        isValidEmail(email) &&
        documents.count > 0
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

