import SwiftUI
import SwiftData
import PhotosUI

struct PickerInteractionProperty {
    var storedKeyboardHeight: CGFloat = 0
    var bragOffset: CGFloat = 0
    var showPhotoPicker: Bool = false
    
    var keyBoardHeight: CGFloat {
        storedKeyboardHeight == 0 ? 300 : storedKeyboardHeight
    }
    
    var safeArea: UIEdgeInsets {
        if let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets {
            return safeArea
        }
        return .zero
    }
    var screenSize: CGSize {
        if let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return size
        }
        return .zero
    }
    var animation: Animation {
        .interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)
    }
}

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.timestamp, order: .forward) private var allMessages: [ChatMessage]

    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var selectedImage: UIImage?
    @State private var showFullScreenImage: (Bool, String?) = (false, nil)
    @FocusState private var isInputFocused: Bool
    
    // iMessage Photo Picker properties
    @State private var properties: PickerInteractionProperty = .init()
    @State private var selectedPhoto: PhotosPickerItem?
    
    // Camera properties
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    // Pagination state
    @State private var displayedMessageCount = 15
    @State private var isLoadingMore = false
    @State private var isInitialLoad = true
    @State private var scrollPosition: String?
    
    private var displayedMessages: [ChatMessage] {
        Array(allMessages.suffix(displayedMessageCount))
    }
    
    private var canLoadMore: Bool {
        displayedMessageCount < allMessages.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
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
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                if allMessages.isEmpty {
                    loadSeedData()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInitialLoad = false
                }
            }
            .safeAreaInset(edge: .bottom) {
                BottomBar()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhoto) { _, newPhoto in
            if let photo = newPhoto {
                loadPhotoData(from: photo)
            }
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                sendImageMessage(image: image)
                capturedImage = nil
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage.0) {
            if let imagePath = showFullScreenImage.1 {
                FullScreenImageView(imagePath: imagePath, isPresented: $showFullScreenImage.0)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(capturedImage: $capturedImage)
        }
    }
    
    @ViewBuilder
    func BottomBar() -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Camera button
            Button {
                if properties.showPhotoPicker {
                    properties.showPhotoPicker = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCamera = true
                    }
                } else {
                    showCamera = true
                }
            } label: {
                Image(systemName: "camera.fill")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: .circle)
                    .contentShape(.circle)
            }
            
            // Photo picker button
            Button {
                properties.showPhotoPicker.toggle()
            } label: {
                Image(systemName: "paperclip")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: .circle)
                    .contentShape(.circle)
            }
            
            TextField("Message...", text: $messageText, axis: .vertical)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 30))
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }
            
            // Send button (only show when there's text)
            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white, .brown)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .geometryGroup()
        .padding(.bottom, animatedKeyBoardHeight)
        .animation(properties.animation, value: animatedKeyBoardHeight)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { info in
            if let frame = info.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = frame.cgRectValue.height
                if properties.storedKeyboardHeight == 0 {
                    properties.storedKeyboardHeight = max(height - properties.safeArea.bottom, 0)
                }
            }
        }
        .sheet(isPresented: $properties.showPhotoPicker) {
            PhotosPicker("", selection: $selectedPhoto)
                .photosPickerStyle(.inline)
                .presentationDetents([.height(properties.keyBoardHeight), .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(properties.keyBoardHeight)))
        }
        .onChange(of: properties.showPhotoPicker) { _, newValue in
            if newValue {
                isInputFocused = false
            }
        }
        .onChange(of: isInputFocused) { _, newValue in
            if newValue {
                properties.showPhotoPicker = false
            }
        }
    }
    
    var animatedKeyBoardHeight: CGFloat {
        (properties.showPhotoPicker || isInputFocused) ? properties.keyBoardHeight : 0
    }
    
    private func loadMoreMessages() {
        guard !isLoadingMore && canLoadMore else { return }
        
        isLoadingMore = true
        let currentFirstMessage = displayedMessages.first?.id
        
        DispatchQueue.main.async {
            displayedMessageCount += 15
            
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
    
    private func loadPhotoData(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    sendImageMessage(image: image)
                    selectedPhoto = nil
                }
            }
        }
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
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
        return fileURL
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

// Camera View using UIImagePickerController
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
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
