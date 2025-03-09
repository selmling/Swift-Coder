//
//  ContentView.swift
//  Swift Coder
//
//  Created by se4433 on 3/5/25.
//

// ContentView.swift

import SwiftUI
import AVKit
import AppKit

struct ContentView: View {
    @State private var videoURLs: [URL] = []
    @State private var videoFolderURL: URL?
    @State private var currentVideoIndex = 0
    @State private var player: AVPlayer?
    @State private var lastSelectedResponse: String?
    @State private var isSelectionConfirmed = false
    @State private var alertIsActive = false
    @State private var isSidebarVisible = false // ✅ Tracks sidebar state

    var body: some View {
        NavigationView {
            if isSidebarVisible {
                SidebarView(videoURLs: videoURLs) { selectedVideo in
                    playVideo(url: selectedVideo)
                    currentVideoIndex = videoURLs.firstIndex(of: selectedVideo) ?? 0
                }
            }

            VStack {
                if videoURLs.isEmpty {
                    SelectVideosView(loadVideos: loadVideos, selectVideoFolder: selectVideoFolder)
                } else {
                    VideoPlayerView(player: player) // ✅ Now properly used inside the view hierarchy
                    AnnotationView(
                        lastSelectedResponse: $lastSelectedResponse,
                        isSelectionConfirmed: $isSelectionConfirmed,
                        saveAnnotation: saveAnnotation
                    )
                }
            }
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.minSize = NSSize(width: 600, height: 370)
            }
        }
        .frame(minWidth: 500, minHeight: 500)
        .padding()
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if alertIsActive { return event } // ✅ Ignore keys if alert is active
                return handleKeyPress(event,
                                      lastSelectedResponse: &lastSelectedResponse,
                                      isSelectionConfirmed: &isSelectionConfirmed,
                                      saveAnnotation: saveAnnotation,
                                      playNextVideo: playNextVideo)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { isSidebarVisible.toggle() }) {
                    Image(systemName: "sidebar.left") // ✅ Standard macOS sidebar toggle icon
                }
            }
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
        do {
            videoFolderURL = folderURL
            
            let videoExtensions = ["mp4", "mov", "m4v"]
            let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            
            videoURLs = files
                .filter { videoExtensions.contains($0.pathExtension.lowercased()) }
                .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
                .filter {
                    let jsonFileURL = folderURL.appendingPathComponent($0.deletingPathExtension().appendingPathExtension("json").lastPathComponent)
                    return !FileManager.default.fileExists(atPath: jsonFileURL.path)
                }
            
            if let nextUnannotated = videoURLs.first {
                currentVideoIndex = 0
                playVideo(url: nextUnannotated)
            } else {
                print("✅ All videos are already annotated.")
                showCompletionAlert()
            }
        } catch {
            print("❌ Error loading videos:", error.localizedDescription)
        }
    }

    private func playVideo(url: URL) {
        player = AVPlayer(url: url)
        print("🎬 Now Playing:", url.lastPathComponent)
    }

    private func playNextVideo() {
        guard !videoURLs.isEmpty, currentVideoIndex + 1 < videoURLs.count else {
            print("✅ No more videos.")
            showCompletionAlert()
            return
        }
        currentVideoIndex += 1
        playVideo(url: videoURLs[currentVideoIndex])
        lastSelectedResponse = nil
        isSelectionConfirmed = false
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

        let annotationFileName = videoURLs[currentVideoIndex]
            .deletingPathExtension()
            .appendingPathExtension("json")
            .lastPathComponent
        let annotationFileURL = videoFolderURL.appendingPathComponent(annotationFileName)

        let annotationData: [String: String] = ["response": response]

        do {
            let data = try JSONSerialization.data(withJSONObject: annotationData, options: .prettyPrinted)
            try data.write(to: annotationFileURL, options: .atomic)
            print("✅ Saved annotation at: \(annotationFileURL.path)")
        } catch {
            print("❌ Error saving annotation:", error.localizedDescription)
        }
    }
}
