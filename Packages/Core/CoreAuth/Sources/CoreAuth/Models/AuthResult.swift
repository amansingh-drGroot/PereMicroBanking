//
//  AuthResult.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public struct User {
    public let userID: String
    public let fullName: String?
    public let email: String?
    public let token: String?
    public let sessionExpiry: Date?
    
    public init(
        userID: String,
        fullName: String? = nil,
        email: String? = nil,
        token: String? = nil,
        sessionExpiry: Date? = nil
    ) {
        self.userID = userID
        self.fullName = fullName
        self.email = email
        self.token = token
        self.sessionExpiry = sessionExpiry
    }
}

public struct AuthResult {
    public let user: User
    public let requiresOTP: Bool
    public let requiresPIN: Bool
    
    public init(user: User, requiresOTP: Bool = false, requiresPIN: Bool = false) {
        self.user = user
        self.requiresOTP = requiresOTP
        self.requiresPIN = requiresPIN
    }
}

