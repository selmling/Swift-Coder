//
//  SelectVideosView.swift
//  Swift Coder
//
//  Created by se4433 on 3/9/25.
//

import SwiftUI

struct SelectVideosView: View {
    var loadVideos: (URL) -> Void
    var selectVideoFolder: () -> Void

    var body: some View {
        VStack {
            Text("Select target videos")
                .padding(.bottom, 5)

            DropTargetView { droppedFolder in
                loadVideos(droppedFolder)
            }

            Button("Open…") {
                selectVideoFolder()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
