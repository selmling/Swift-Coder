//
//  SidebarView.swift
//  Swift Coder
//
//  Created by se4433 on 3/8/25.
//

import SwiftUI

struct SidebarView: View {
    var videoURLs: [URL]
    var onSelectVideo: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Media:")
                .font(.headline)
                .padding(.bottom, 5)

            List(videoURLs, id: \.self) { video in
                Button(video.lastPathComponent) {
                    onSelectVideo(video)
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
