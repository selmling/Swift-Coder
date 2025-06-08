//
//  SidebarView.swift
//  Swift Coder
//
//  Created by se4433 on 3/8/25.
//

import SwiftUI

struct SidebarView: View {
    var videoURLs: [URL]
    var currentVideo: URL?
    var onSelectVideo: (URL) -> Void
    var userName: String  // The current signed‑in name
    var onSignInAgain: () -> Void  // Callback to re-trigger sign in

    var body: some View {
        VStack(alignment: .leading) {
            // Display the signed-in name as non-interactive text with a context menu.
            if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                Text("Signed in as: \(userName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                    .contextMenu {
                        Button("Sign in…") {
                            onSignInAgain()
                        }
                    }
            }
            
            Text("Media:")
                .font(.headline)
                .padding(.bottom, 5)

            List(videoURLs, id: \.self) { video in
                Button(action: { onSelectVideo(video) }) {
                        Text(video.lastPathComponent)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(video == currentVideo ? Color.accentColor.opacity(0.2) : Color.clear)
                            .cornerRadius(6)
                    }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
            }
            .frame(minWidth: 220)
        }
        .padding()
        .frame(minWidth: 220)
    }
}
