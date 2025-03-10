//
//  videoPlayerView.swift
//  Swift Coder
//
//  Created by se4433 on 3/9/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var player: AVPlayer? // ✅ Accepts player from ContentView.swift

    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 400)
            } else {
                Text("No media selected")
                    .frame(height: 400)
            }
        }
    }
}
