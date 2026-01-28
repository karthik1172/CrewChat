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
    @FocusState private var isInputFocused: Bool
    
    // iMessage Photo Picker properties
    @State private var properties: PickerInteractionProperty = .init()
    
    private var displayedMessages: [ChatMessage] {
        viewModel.getDisplayedMessages(from: allMessages)
    }
    
    private var canLoadMore: Bool {
        viewModel.canLoadMore(totalMessages: allMessages.count)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Load more indicator at top
                        if canLoadMore {
                            LoadMoreView(isLoading: $viewModel.isLoadingMore)
                        }
                        
                        ForEach(Array(displayedMessages.enumerated()), id: \.element.id) { index, message in
                            MessageBubbleView(
                                chatMessage: message,
                                onImageTap: { imagePath in
                                    viewModel.loadImageForFullScreen(path: imagePath)
                                }
                            )
                            .id(message.id)
                            .onAppear {
                                if !viewModel.isInitialLoad && index == 4 && canLoadMore {
                                    viewModel.loadMoreMessages(currentFirstMessageId: displayedMessages.first?.id)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                .scrollPosition(id: $viewModel.scrollPosition, anchor: .bottom)
                .defaultScrollAnchor(.bottom)
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    viewModel.setModelContext(modelContext)
                    if allMessages.isEmpty {
                        viewModel.loadSeedData(into: modelContext)
                    }
                    viewModel.completeInitialLoad()
                }
                .safeAreaInset(edge: .bottom) {
                    BottomBar()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .all)
            
            // Full screen image overlay
            if let image = viewModel.fullScreenImage {
                FullScreenImageOverlay(image: image, isPresented: Binding(
                    get: { viewModel.fullScreenImage != nil },
                    set: { if !$0 { viewModel.dismissFullScreenImage() } }
                ))
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.selectedPhoto) { _, newPhoto in
            if let photo = newPhoto {
                viewModel.loadPhotoData(from: photo)
            }
        }
        .onChange(of: viewModel.capturedImage) { _, newImage in
            viewModel.handleCapturedImage(newImage)
        }
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            CameraView(capturedImage: $viewModel.capturedImage)
                .ignoresSafeArea()
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
                        viewModel.showCamera = true
                    }
                } else {
                    viewModel.showCamera = true
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
            
            TextField("Message...", text: $viewModel.messageText, axis: .vertical)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 30))
                .focused($isInputFocused)
                .onSubmit {
                    handleSendMessage()
                }
            
            // Send button
            if !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    handleSendMessage()
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
        /// extracting keyboard height
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { info in
            if let frame = info.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = frame.cgRectValue.height
                if properties.storedKeyboardHeight == 0 {
                    properties.storedKeyboardHeight = max(height - properties.safeArea.bottom, 0)
                }
            }
        }
        .sheet(isPresented: $properties.showPhotoPicker) {
            PhotosPicker("", selection: $viewModel.selectedPhoto)
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
    
    private func handleSendMessage() {
        viewModel.sendTextMessage()
        isInputFocused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.scrollToBottom(lastMessageId: displayedMessages.last?.id)
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
