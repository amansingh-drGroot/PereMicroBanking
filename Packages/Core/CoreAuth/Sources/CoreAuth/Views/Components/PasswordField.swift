//
//  PasswordField.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI

public struct PasswordField: View {
    @Binding var password: String
    let placeholder: String
    @State private var isSecure: Bool = true
    
    public init(password: Binding<String>, placeholder: String = "Password") {
        self._password = password
        self.placeholder = placeholder
    }
    
    public var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $password)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
    }
}

