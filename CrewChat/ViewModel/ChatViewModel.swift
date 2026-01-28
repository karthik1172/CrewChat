//
//  ChatViewModel.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI
import SwiftData

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""
    @Published var selectedImage: UIImage?
    @Published var fullScreenImage: UIImage?
    @Published var displayedMessageCount = 15
    @Published var isLoadingMore = false
    @Published var isInitialLoad = true
    @Published var scrollPosition: String?
    
    // Photo picker
    @Published var selectedPhoto: PhotosPickerItem?
    
    // Camera
    @Published var showCamera = false
    @Published var capturedImage: UIImage?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Computed Properties
    
    func getDisplayedMessages(from allMessages: [ChatMessage]) -> [ChatMessage] {
        Array(allMessages.suffix(displayedMessageCount))
    }
    
    func canLoadMore(totalMessages: Int) -> Bool {
        displayedMessageCount < totalMessages
    }
    
    // MARK: - Pagination
    
    func loadMoreMessages(currentFirstMessageId: String?) {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.displayedMessageCount += 15
            
            if let firstMessageId = currentFirstMessageId {
                self.scrollPosition = firstMessageId
            }
            
            self.isLoadingMore = false
        }
    }
    
    func scrollToBottom(lastMessageId: String?) {
        if let id = lastMessageId {
            withAnimation {
                scrollPosition = id
            }
        }
    }
    
    func completeInitialLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isInitialLoad = false
        }
    }
    
    // MARK: - Message Sending
    
    func sendTextMessage() {
        guard let context = modelContext else { return }
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            message: messageText,
            type: "text",
            sender: "user",
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        context.insert(newMessage)
        messageText = ""
        
        return
    }
    
    func sendImageMessage(image: UIImage, completion: @escaping () -> Void) {
        guard let context = modelContext else { return }
        
        Task {
            let fileName = "\(UUID().uuidString).jpg"
            
            if let imageURL = await ImageLoader.shared.saveImage(image, fileName: fileName) {
                let fileSize = ImageLoader.shared.getFileSize(at: imageURL.path) ?? 0
                
                let newMessage = ChatMessage(
                    id: UUID().uuidString,
                    message: "Image attachment",
                    type: "file",
                    filePath: imageURL.path,
                    fileSize: fileSize,
                    sender: "user",
                    timestamp: Int64(Date().timeIntervalSince1970 * 1000)
                )
                
                await MainActor.run {
                    context.insert(newMessage)
                    completion()
                }
            }
        }
    }
    
    // MARK: - Image Handling
    
    func loadImageForFullScreen(path: String) {
        Task {
            if let image = await ImageLoader.shared.loadImage(from: path) {
                await MainActor.run { [weak self] in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self?.fullScreenImage = image
                    }
                }
            }
        }
    }
    
    func dismissFullScreenImage() {
        fullScreenImage = nil
    }
    
    func loadPhotoData(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.sendImageMessage(image: image) {}
                    self.selectedPhoto = nil
                }
            }
        }
    }
    
    func handleCapturedImage(_ image: UIImage?) {
        guard let image = image else { return }
        sendImageMessage(image: image) {}
        capturedImage = nil
    }
    
    // MARK: - Seed Data
    
    func loadSeedData(into context: ModelContext) {
        let seedMessages = getSeedMessages()
        for message in seedMessages {
            context.insert(message)
        }
    }
    
    func getSeedMessages() -> [ChatMessage] {
        return [
            ChatMessage(id: "msg-001", message: "Hi! I need help booking a flight to Mumbai.", type: "text", sender: "user", timestamp: 1703520000000),
            ChatMessage(id: "msg-002", message: "Hello! I'd be happy to help you book a flight to Mumbai. When are you planning to travel?", type: "text", sender: "agent", timestamp: 1703520030000),
            ChatMessage(id: "msg-003", message: "Next Friday, December 29th.", type: "text", sender: "user", timestamp: 1703520090000),
            ChatMessage(id: "msg-004", message: "Great! And when would you like to return?", type: "text", sender: "agent", timestamp: 1703520120000),
            ChatMessage(id: "msg-005", message: "January 5th. Also, I prefer morning flights.", type: "text", sender: "user", timestamp: 1703520180000),
            ChatMessage(id: "msg-006", message: "Perfect! Let me search for morning flights. Could you share your departure city?", type: "text", sender: "agent", timestamp: 1703520210000),
            ChatMessage(id: "msg-007", message: "Bangalore.", type: "text", sender: "user", timestamp: 1703520240000),
            ChatMessage(id: "msg-008", message: "Got it 👍 Searching flights from Bangalore to Mumbai.", type: "text", sender: "agent", timestamp: 1703520270000),
            ChatMessage(id: "msg-009", message: "", type: "file",
                        filePath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400",
                        fileSize: 245680,
                        thumbnailPath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=100",
                        sender: "user",
                        timestamp: 1703520300000),
            ChatMessage(id: "msg-010", message: "Thanks! I see you prefer IndiGo. Here are some options.", type: "text", sender: "agent", timestamp: 1703520330000),
            ChatMessage(id: "msg-011", message: "Flight options comparison", type: "file",
                        filePath: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=400",
                        fileSize: 189420,
                        thumbnailPath: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=100",
                        sender: "agent",
                        timestamp: 1703520420000),
            ChatMessage(id: "msg-012", message: "The second option looks perfect! How do I proceed?", type: "text", sender: "user", timestamp: 1703520480000)
        ]
    }
}
