//
//  DropTargetView.swift
//  Swift Coder
//
//  Created by se4433 on 3/8/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropTargetView: View {
    var onDrop: (URL) -> Void
    @State private var isDragging = false // ✅ Tracks when a folder is dragged over

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(isDragging ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5])) // ✅ Changes to blue when dragging
            .frame(width: 300, height: 100)
            .overlay(Text("Drag & Drop Video Folder Here").foregroundColor(.gray))
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDragging) { providers in
                handleDrop(providers)
            }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                    DispatchQueue.main.async {
                        if let urlData = item as? Data,
                           let urlString = String(data: urlData, encoding: .utf8),
                           let url = URL(string: urlString) {
                            
                            onDrop(url) // ✅ Process the dropped folder
                            NSApplication.shared.activate(ignoringOtherApps: true) // ✅ Bring app to front
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}
