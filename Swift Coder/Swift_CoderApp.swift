//
//  Swift_CoderApp.swift
//  Swift Coder
//
//  Created by se4433 on 3/5/25.
//

import SwiftUI

@main
struct Swift_CoderApp: App {
    @State private var showSignInSheet: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView(showSignInSheet: $showSignInSheet)
        }
        .commands {
            // Insert our "Sign in…" command into the existing File menu.
            CommandGroup(after: .newItem) {
                Button("Sign in…") {
                    showSignInSheet = true
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }
}
