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
            // Insert "Report a Bug" under Help menu
            CommandGroup(after: .help) {
                Divider()
                Button("Report a Bug") {
                    if let url = URL(string: "https://github.com/selmling/Swift-Coder/issues/new/choose") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
            }
            CommandGroup(after: .appSettings) {
                Button("Check for Updates…") {
                    guard let url = URL(string: "https://github.com/selmling/Swift-Coder/releases/latest") else { return }
                    NSWorkspace.shared.open(url)
                }
                .keyboardShortcut("u", modifiers: [.command, .option])}
            }
        }
    }
