//
//  videoPlayerView.swift
//  Swift Coder
//
//  Created by se4433 on 3/9/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let player: AVPlayer?

    var body: some View {
        if let player = player {
            // ▶︎ Use our AVPlayerViewContainer instead of VideoPlayer
            AVPlayerViewContainer(player: player)
                // You can give it a minimum height or aspect ratio if desired:
                .frame(minHeight: 240)
        } else {
            Text("No video selected")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
