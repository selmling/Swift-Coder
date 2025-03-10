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
    @State private var userName: String = ""     // User sign‑in name
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @Binding var showSignInSheet: Bool
    @State private var isPlaybackPending: Bool = false
    @State private var isSignedIn: Bool = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(videoURLs: videoURLs,
                        onSelectVideo: { selectedVideo in
                            playVideo(url: selectedVideo)
                            currentVideoIndex = videoURLs.firstIndex(of: selectedVideo) ?? 0
                        },
                        userName: userName,
                        onSignInAgain: {
                            showSignInSheet = true
                            isSignedIn = false
                        })
        } detail: {
            if videoURLs.isEmpty {
                SelectVideosView(loadVideos: loadVideos, selectVideoFolder: selectVideoFolder)
            } else {
                VStack {
                    VideoPlayerView(player: player)
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
                return handleKeyPress(event,
                                      lastSelectedResponse: &lastSelectedResponse,
                                      isSelectionConfirmed: &isSelectionConfirmed,
                                      saveAnnotation: saveAnnotation,
                                      playNextVideo: playNextVideo)
            }
        }
        .frame(minWidth: 500, minHeight: 500)
        .padding()
        .sheet(isPresented: $showSignInSheet, onDismiss: {
            if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                isSignedIn = true
                if isPlaybackPending && !videoURLs.isEmpty {
                    playVideo(url: videoURLs[currentVideoIndex])
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
                if userName.trimmingCharacters(in: .whitespaces).isEmpty {
                    isPlaybackPending = true
                    showSignInSheet = true
                } else {
                    playVideo(url: nextUnannotated)
                }
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

        let baseName = videoURLs[currentVideoIndex].deletingPathExtension().lastPathComponent
        let annotationFileName = "\(baseName)_\(userName).json"
        
        let annotationFileURL = videoFolderURL.appendingPathComponent(annotationFileName)

        let annotationData: [String: String] = [
                "response": response,
                "user": userName  // <-- This line adds the username
            ]

        do {
            let data = try JSONSerialization.data(withJSONObject: annotationData, options: .prettyPrinted)
            try data.write(to: annotationFileURL, options: .atomic)
            print("✅ Saved annotation at: \(annotationFileURL.path)")
        } catch {
            print("❌ Error saving annotation:", error.localizedDescription)
        }
    }
}
