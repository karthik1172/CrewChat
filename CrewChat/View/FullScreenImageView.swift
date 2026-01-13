//
//  FullScreenImageView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI

struct FullScreenImageView: View {
    let imagePath: String
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                
                Group {
                    if imagePath.hasPrefix("http") {
                        AsyncImage(url: URL(string: imagePath)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .scaleEffect(scale)
                                    .gesture(magnificationGesture)
                            default:
                                ProgressView()
                            }
                        }
                    } else {
                        if let uiImage = UIImage(contentsOfFile: imagePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .gesture(magnificationGesture)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            print("FullScreen opened")
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
                if scale < 1.0 {
                    withAnimation {
                        scale = 1.0
                        lastScale = 1.0
                    }
                } else if scale > 4.0 {
                    withAnimation {
                        scale = 4.0
                        lastScale = 4.0
                    }
                }
            }
    }
}
