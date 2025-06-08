//
//  AnnotationView.swift
//  Swift Coder
//
//  Created by se4433 on 3/9/25.
//

import SwiftUI

struct AnnotationView: View {
    @Binding var lastSelectedResponse: String?
    @Binding var isSelectionConfirmed: Bool
    var saveAnnotation: (String) -> Void

    var body: some View {
        VStack {
            Text("Is the child asking a question?")
                .font(.title2)
                .padding(.top, 10)

            HStack {
                responseButton(for: "Yes")
                responseButton(for: "No")
            }
            .padding(.top, 10)

            if lastSelectedResponse == nil {
                Text("Make a selection")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                Text("Press Enter to continue…")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
        }
    }

    private func responseButton(for response: String) -> some View {
        Button(response) {
            lastSelectedResponse = response
            isSelectionConfirmed = false
        }
        .keyboardShortcut(response == "Yes" ? "y" : "n")
        .buttonStyle(.plain)
        .controlSize(.regular)
        .padding(6)
        .background(lastSelectedResponse == response ? Color.blue : Color.white)
        .foregroundColor(lastSelectedResponse == response ? Color.white : Color.black)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
