//
//  LoginCredentials.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public struct LoginCredentials {
    public let userID: String
    public let password: String
    public var pin: String?
    public var otp: String?
    
    public init(userID: String, password: String, pin: String? = nil, otp: String? = nil) {
        self.userID = userID
        self.password = password
        self.pin = pin
        self.otp = otp
    }
    
    public var isValid: Bool {
        !userID.isEmpty && !password.isEmpty
    }
}

