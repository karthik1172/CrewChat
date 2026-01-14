import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.timestamp, order: .forward)
    private var allMessages: [ChatMessage]
    
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showFullScreenImage: (Bool, String?) = (false, nil)
    @FocusState private var isInputFocused: Bool
    
    // Pagination state
    @State private var displayedMessageCount = 15
    @State private var isLoadingMore = false
    @State private var isInitialLoad = true
    @State private var scrollPosition: String?
    
    private var displayedMessages: [ChatMessage] {
        // Get the latest N messages
        Array(allMessages.suffix(displayedMessageCount))
    }
    
    private var canLoadMore: Bool {
        displayedMessageCount < allMessages.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List - Rotated approach for bottom-anchored scrolling
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Load more indicator at top
                    if canLoadMore {
                        LoadMoreView(isLoading: $isLoadingMore)
                    }
                    
                    ForEach(Array(displayedMessages.enumerated()), id: \.element.id) { index, message in
                        MessageBubbleView(
                            chatMessage: message,
                            onImageTap: { imagePath in
                                showFullScreenImage = (true, imagePath)
                            }
                        )
                        .id(message.id)
                        .onAppear {
                            // Preload when reaching 5th message from the START (oldest messages)
                            // Since messages are ordered oldest to newest, index 4 means 5th oldest
                            if !isInitialLoad && index == 4 && canLoadMore {
                                loadMoreMessages()
                            }
                        }
                    }
                }
                .padding()
            }
            .scrollPosition(id: $scrollPosition, anchor: .top)
            .defaultScrollAnchor(.bottom)
            .onAppear {
                if allMessages.isEmpty {
                    loadSeedData()
                }
                // Mark initial load as complete after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInitialLoad = false
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
    
    private func loadMoreMessages() {
        guard !isLoadingMore && canLoadMore else { return }
        
        isLoadingMore = true
        
        // Save the current first visible message to maintain scroll position
        let currentFirstMessage = displayedMessages.first?.id
        
        // Load immediately without delay for seamless experience
        DispatchQueue.main.async {
            // Increase count smoothly
            displayedMessageCount += 15
            
            // Restore scroll position to the message that was at top
            if let firstMessageId = currentFirstMessage {
                scrollPosition = firstMessageId
            }
            
            isLoadingMore = false
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
        guard
            let data = image.jpegData(compressionQuality: 0.8),
            let documentsDirectory = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first
        else {
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to write image: \(error)")
            return nil
        }
    }
    
    private func getFileSize(url: URL) -> Int {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int else { return 0 }
        return fileSize
    }
    
    private func loadSeedData() {
        let seedMessages = viewModel.getSeedMessages()
        for message in seedMessages {
            modelContext.insert(message)
        }
    }
}

// Load More Indicator View
struct LoadMoreView: View {
    @Binding var isLoading: Bool
    
    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text("Loading more messages...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
