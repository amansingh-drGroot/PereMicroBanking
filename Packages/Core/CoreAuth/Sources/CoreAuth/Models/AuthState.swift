//
//  AuthState.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import Foundation

public enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case error(String)
}

