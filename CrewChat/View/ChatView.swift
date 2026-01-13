//
//  ChatView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.timestamp, order: .forward) private var messages: [ChatMessage]
    
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showFullScreenImage: (Bool, String?) = (false, nil)
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(
                                chatMessage: message,
                                onImageTap: { imagePath in
                                    showFullScreenImage = (true, imagePath)
                                }
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onAppear {
                    if messages.isEmpty {
                        loadSeedData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            
            // Input Bar
            InputBar(
                messageText: $messageText,
                isInputFocused: $isInputFocused,
                onSend: sendMessage,
                onImagePicker: { showImagePicker = true },
                onCamera: { showCamera = true }
            )
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                sendImageMessage(image: image)
                selectedImage = nil
            }
        }
        .onChange(of:showFullScreenImage.0 ) { oldValue, newValue in
            print("new value", newValue)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .fullScreenCover(isPresented: $showFullScreenImage.0) {
            if let imagePath = showFullScreenImage.1 {
                FullScreenImageView(imagePath: imagePath, isPresented: $showFullScreenImage.0)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            message: messageText,
            type: "text",
            sender: "user",
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        modelContext.insert(newMessage)
        messageText = ""
        isInputFocused = false
    }
    
    private func sendImageMessage(image: UIImage) {
        // Save image to documents directory
        let fileName = "\(UUID().uuidString).jpg"
        if let imageURL = saveImage(image: image, fileName: fileName) {
            let fileSize = getFileSize(url: imageURL)
            
            let newMessage = ChatMessage(
                id: UUID().uuidString,
                message: "Image attachment",
                type: "file",
                filePath: imageURL.path,
                fileSize: fileSize,
                sender: "user",
                timestamp: Int64(Date().timeIntervalSince1970 * 1000)
            )
            
            modelContext.insert(newMessage)
        }
    }
    
    private func saveImage(image: UIImage, fileName: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        try? data.write(to: fileURL)
        return fileURL
    }
    
    private func getFileSize(url: URL) -> Int {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int else {
            return 0
        }
        return fileSize
    }
    
    private func loadSeedData() {
        let seedMessages = viewModel.getSeedMessages()
        for message in seedMessages {
            modelContext.insert(message)
        }
    }
}
