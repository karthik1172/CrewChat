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
                if let uiImage = UIImage(contentsOfFile: filePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 150)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Image(systemName: "photo")
                        .frame(width: 200, height: 150)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
    }
}
