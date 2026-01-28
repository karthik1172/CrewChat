//
//  ImageMessageView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI

struct ImageMessageView: View {
    let filePath: String
    let thumbnailPath: String?
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var loadError = false
    
    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 150)
                    .clipped()
                    .cornerRadius(8)
            } else if loadError {
                Image(systemName: "photo")
                    .frame(width: 200, height: 150)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ZStack {
                    Color(.systemGray6)
                    if isLoading {
                        ProgressView()
                    }
                }
                .frame(width: 200, height: 150)
                .cornerRadius(8)
            }
        }
        .onAppear(perform: {
            Task {
                await loadImage()
            }
        })
    }
    
    private func loadImage() async {
        guard loadedImage == nil, !isLoading else { return }
        
        isLoading = true
        loadError = false
        
        let pathToLoad = filePath.hasPrefix("http") ? (thumbnailPath ?? filePath) : filePath
        
        if let image = await ImageLoader.shared.loadImage(from: pathToLoad) {
            await MainActor.run {
                self.loadedImage = image
                self.isLoading = false
            }
        } else {
            await MainActor.run {
                self.loadError = true
                self.isLoading = false
            }
        }
    }
}
