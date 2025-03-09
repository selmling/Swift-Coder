//
//  KeyboardHandler.swift
//  Swift Coder
//
//  Created by se4433 on 3/9/25.
//

import AppKit

func handleKeyPress(
    _ event: NSEvent,
    lastSelectedResponse: inout String?,
    isSelectionConfirmed: inout Bool,
    saveAnnotation: (String) -> Void,
    playNextVideo: () -> Void
) -> NSEvent? {
    
    switch event.charactersIgnoringModifiers {
    case "y":
        lastSelectedResponse = "Yes"
        isSelectionConfirmed = false
        saveAnnotation("Yes")
    case "n":
        lastSelectedResponse = "No"
        isSelectionConfirmed = false
        saveAnnotation("No")
    default:
        break
    }

    if event.keyCode == 36 || event.keyCode == 76 { // Enter or Return key
        if lastSelectedResponse != nil {
            isSelectionConfirmed = true
            lastSelectedResponse = nil // ✅ Reset selection before advancing
            playNextVideo()
        }
        return nil
    }

    return event
}
