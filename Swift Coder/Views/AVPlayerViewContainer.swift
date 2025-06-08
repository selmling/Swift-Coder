// AVPlayerViewContainer.swift
// Swift Coder
//
// Created by se4433 on 6/5/25.
//

import SwiftUI
import AVKit

/// A SwiftUI wrapper around AppKit’s AVPlayerView.
/// Use this in place of VideoPlayer on macOS.
struct AVPlayerViewContainer: NSViewRepresentable {
    let player: AVPlayer
    var showsControls: Bool = true

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        
        // Replace `showsPlaybackControls` with `controlsStyle`:
        view.controlsStyle = showsControls ? .default : .none
        
        view.showsFullScreenToggleButton = true
        view.videoGravity = .resizeAspect
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player !== player {
            nsView.player = player
        }
        nsView.controlsStyle = showsControls ? .default : .none
    }

    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: ()) {
        nsView.player = nil
    }
}
