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
    
    var body: some View {
        Group {
            if filePath.hasPrefix("http") {
                AsyncImage(url: URL(string: thumbnailPath ?? filePath)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 200, height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 150)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo")
                            .frame(width: 200, height: 150)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 150)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ZStack {
                        Color(.systemGray6)
                        ProgressView()
                    }
                    .frame(width: 200, height: 150)
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            loadLocalImage()
        }
    }
    
    private func loadLocalImage() {
        guard !filePath.hasPrefix("http") else { return }
        guard loadedImage == nil else { return }
        
        Task {
            if let image = await ImageLoader.shared.loadImage(from: filePath) {
                await MainActor.run {
                    self.loadedImage = image
                }
            }
        }
    }
}
