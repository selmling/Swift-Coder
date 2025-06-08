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
    playNextVideo: () -> Void,
    togglePlayPause: () -> Void
) -> NSEvent? {

    switch event.charactersIgnoringModifiers {
    case "y", "Y":
        lastSelectedResponse = "Yes"
        isSelectionConfirmed = false
        saveAnnotation("Yes")
        return nil
    case "n", "N":
        lastSelectedResponse = "No"
        isSelectionConfirmed = false
        saveAnnotation("No")
        return nil
    case "\r":  // Enter/Return
        if let response = lastSelectedResponse {
            isSelectionConfirmed = true
            saveAnnotation(response)
            playNextVideo()
        }
        return nil
    case " ":  // Spacebar
        togglePlayPause()
        return nil
    default:
        return event
    }
}
