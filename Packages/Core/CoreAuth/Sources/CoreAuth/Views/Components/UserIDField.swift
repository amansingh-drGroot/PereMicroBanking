//
//  UserIDField.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI

public struct UserIDField: View {
    @Binding var userID: String
    let placeholder: String
    
    public init(userID: Binding<String>, placeholder: String = "User ID / Customer ID") {
        self._userID = userID
        self.placeholder = placeholder
    }
    
    public var body: some View {
        TextField(placeholder, text: $userID)
            .textContentType(.username)
            .autocapitalization(.none)
            .keyboardType(.default)
            .disableAutocorrection(true)
    }
}

