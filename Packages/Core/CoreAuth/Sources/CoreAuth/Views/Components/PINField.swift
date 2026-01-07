//
//  PINField.swift
//  CoreAuth
//
//  Created by Aman Singh on 05/01/26.
//

import SwiftUI

public struct PINField: View {
    @Binding var pin: String
    let placeholder: String
    
    public init(pin: Binding<String>, placeholder: String = "PIN") {
        self._pin = pin
        self.placeholder = placeholder
    }
    
    public var body: some View {
        SecureField(placeholder, text: $pin)
            .keyboardType(.numberPad)
            .textContentType(.none)
    }
}

