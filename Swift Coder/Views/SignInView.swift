//
//  SignInView.swift
//  Swift Coder
//
//  Created by se4433 on 3/9/25.
//

import SwiftUI

struct SignInView: View {
    @Binding var userName: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign in, please...")
                .font(.title2)
                .foregroundColor(.secondary)
            TextField("Enter your name", text: $userName, onCommit: {
                // This block executes when the user presses Enter/Return
                if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                    dismiss()
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 250)
            
            Button("Sign In") {
                if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                    dismiss()
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .frame(width: 300, height: 150)
    }
}
