//
//  ContentView.swift
//  Swift Coder
//
//  Created by se4433 on 3/5/25.
//

// ContentView.swift

import SwiftUI
import AVKit
import UniformTypeIdentifiers
import AVFoundation

struct ContentView: View {
    @State private var videoURLs: [URL] = []
    @State private var videoFolderURL: URL?
    @State private var currentVideoIndex = 0
    @State private var player: AVPlayer?
    @State private var lastSelectedResponse: String?
    @State private var isSelectionConfirmed = false
    @State private var alertIsActive = false
    @State private var userName: String = ""     // User sign‑in name
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @Binding var showSignInSheet: Bool
    @State private var isPlaybackPending: Bool = false
    @State private var isSignedIn: Bool = false
    @State private var currentVideo: URL? = nil
    @State private var isLoading: Bool = false
    @State private var preloadPlayers: [Int: AVPlayerItem] = [:]
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(videoURLs: videoURLs,
                        currentVideo: currentVideo,
                        onSelectVideo: { selectedVideo in
                            playVideo(url: selectedVideo)
                            currentVideoIndex = videoURLs.firstIndex(of: selectedVideo) ?? 0
                            currentVideo = selectedVideo
                        },
                        userName: userName,
                        onSignInAgain: {
                            showSignInSheet = true
                            isSignedIn = false
                        })
        } detail: {
            if isLoading {
                ProgressView("Loading videos...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if videoURLs.isEmpty {
                SelectVideosView(loadVideos: loadVideos, selectVideoFolder: selectVideoFolder)
            } else {
                VStack {
                    if let avp = player {
                        AVPlayerViewContainer(player: avp, showsControls: true)
                            .frame(minWidth: 600, minHeight: 400)
                    } else {
                        Text("Loading…")
                            .frame(minWidth: 600, minHeight: 400)
                    }
                    if !isSignedIn {
                        Text("Please sign in to annotate.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        AnnotationView(
                            lastSelectedResponse: $lastSelectedResponse,
                            isSelectionConfirmed: $isSelectionConfirmed,
                            saveAnnotation: saveAnnotation
                        )
                    }
                }
            }
        }
        .onAppear {
            columnVisibility = .detailOnly
            // Set minimum window size
            if let window = NSApplication.shared.windows.first {
                window.minSize = NSSize(width: 600, height: 370)
            }
            // Set up key handling
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // If an alert is active, just return the event
                if alertIsActive { return event }
                // Check if the main window has an attached sheet (i.e. the sign-in sheet)
                if let mainWindow = NSApplication.shared.mainWindow,
                   mainWindow.attachedSheet != nil {
                    // If a sheet is attached, don't handle the event here.
                    return event
                }
                return handleKeyPress(
                    event,
                    lastSelectedResponse: &lastSelectedResponse,
                    isSelectionConfirmed: &isSelectionConfirmed,
                    saveAnnotation: saveAnnotation,
                    playNextVideo: playNextVideo,
                    togglePlayPause: togglePlayPause
                )
            }
        }
        .frame(minWidth: 500, minHeight: 500)
        .padding()
        .sheet(isPresented: $showSignInSheet, onDismiss: {
            if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                isSignedIn = true
                if isPlaybackPending {
                            if let next = nextUnannotatedIndex() {
                                currentVideoIndex = next
                                playVideo(url: videoURLs[next])
                            } else {
                                showCompletionAlert()
                            }
                            isPlaybackPending = false
                        }
            }
        }) {
            SignInView(userName: $userName)
                .interactiveDismissDisabled(true) 
        }
    }
    
    private func selectVideoFolder() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose Video Folder"
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false

        if dialog.runModal() == .OK, let folderURL = dialog.url {
            loadVideos(from: folderURL)
        }
    }

    private func loadVideos(from folderURL: URL) {
      isLoading = true
      DispatchQueue.global(qos: .userInitiated).async {
        let exts = ["mp4","mov","m4v"]
        let all = (try? FileManager.default
                    .contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil))
                  ?? []
        let videos = all
          .filter { exts.contains($0.pathExtension.lowercased()) }
          .sorted { $0.lastPathComponent < $1.lastPathComponent }
        DispatchQueue.main.async {
          videoFolderURL = folderURL
          videoURLs = videos
          isLoading = false

          // we haven't signed in yet, so buffer playback
          isPlaybackPending = true
          showSignInSheet = true
        }
      }
    }

    
    private func preloadUpcomingVideos() {
        preloadPlayers.removeAll()

        let preloadRange = (currentVideoIndex + 1)...min(currentVideoIndex + 100, videoURLs.count - 1)

        for i in preloadRange {
            let url = videoURLs[i]
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            item.preferredForwardBufferDuration = 5
            preloadPlayers[i] = item
        }
    }

    private func playVideo(url: URL) {
        let index = videoURLs.firstIndex(of: url) ?? 0

        if let preloadedItem = preloadPlayers[index] {
            player = AVPlayer(playerItem: preloadedItem)
        } else {
            player = AVPlayer(url: url)
        }

        currentVideo = url
        print("🎬 Now Playing:", url.lastPathComponent)

        preloadUpcomingVideos()
    }

    private func playNextVideo() {
        guard !videoURLs.isEmpty, currentVideoIndex + 1 < videoURLs.count else {
            print("✅ No more videos.")
            showCompletionAlert()
            return
        }
        currentVideoIndex += 1
        lastSelectedResponse = nil
        isSelectionConfirmed = false

        // Slight delay to allow UI update before video load
        DispatchQueue.main.async {
            playVideo(url: videoURLs[currentVideoIndex])
        }
    }

    private func annotationView() -> some View {
        AnnotationView(
            lastSelectedResponse: $lastSelectedResponse,
            isSelectionConfirmed: $isSelectionConfirmed,
            saveAnnotation: saveAnnotation
        )
    }
    
    private func showCompletionAlert() {
        alertIsActive = true
        let alert = NSAlert()
        alert.messageText = "Annotation complete."
        alert.informativeText = "Quit Swift Coder?"
        alert.alertStyle = .informational
        let yesButton = alert.addButton(withTitle: "Yes")
        yesButton.keyEquivalent = "\r"

        if alert.runModal() == .alertFirstButtonReturn {
            NSApplication.shared.terminate(nil)
        }
        alertIsActive = false
    }

    private func saveAnnotation(_ response: String) {
        guard let videoFolderURL = videoFolderURL else {
            print("❌ No video folder selected. Cannot save annotations.")
            return
        }

        let baseName = videoURLs[currentVideoIndex].deletingPathExtension().lastPathComponent
        let annotationFileName = "\(baseName)_\(userName).json"
        let annotationFileURL = videoFolderURL.appendingPathComponent(annotationFileName)

        let annotationData: [String: String] = [
            "response": response,
            "user": userName
        ]

        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONSerialization.data(withJSONObject: annotationData, options: .prettyPrinted)
                try data.write(to: annotationFileURL, options: .atomic)
                print("✅ Saved annotation at: \(annotationFileURL.path)")
            } catch {
                print("❌ Error saving annotation:", error.localizedDescription)
            }
        }
    }
    
    /// Returns the index of the first video without a `<basename>_<userName>.json`.
        /// If they’re all annotated, returns `nil`.
        private func nextUnannotatedIndex() -> Int? {
          guard let folder = videoFolderURL,
                !userName.trimmingCharacters(in: .whitespaces).isEmpty
          else { return nil }

          return videoURLs.firstIndex { url in
            let base     = url.deletingPathExtension().lastPathComponent
            let jsonName = "\(base)_\(userName).json"
            let jsonURL  = folder.appendingPathComponent(jsonName)
            return !FileManager.default.fileExists(atPath: jsonURL.path)
          }
        }
    
    private func togglePlayPause() {
        guard let player = player else {
            print("⚠️ No player loaded")
            return
        }

        if player.currentItem?.currentTime() == player.currentItem?.duration {
            // If the video already finished, rewind to start
            player.seek(to: .zero)
            player.play()
        } else if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
}
