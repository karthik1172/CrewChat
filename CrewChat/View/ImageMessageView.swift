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
        guard loadedImage == nil else { return } // Don't reload if already loaded
        
        // Try multiple loading strategies
        DispatchQueue.global(qos: .userInitiated).async {
            var image: UIImage?
            
            // Strategy 1: Direct path
            image = UIImage(contentsOfFile: filePath)
            
            // Strategy 2: Reconstruct from filename
            if image == nil {
                let fileName = (filePath as NSString).lastPathComponent
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    image = UIImage(contentsOfFile: fileURL.path)
                }
            }
            
            // Strategy 3: Data initializer
            if image == nil {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                    image = UIImage(data: data)
                }
            }
            
            if let finalImage = image {
                DispatchQueue.main.async {
                    self.loadedImage = finalImage
                }
            } else {
                print("❌ ImageMessageView: Failed to load \(filePath)")
            }
        }
    }
}
