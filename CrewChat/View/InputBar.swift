//
//  InputBar.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import Foundation
import SwiftUI

struct InputBar: View {
    @Binding var messageText: String
    var isInputFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    let onImagePicker: () -> Void
    let onCamera: () -> Void
    
    @State private var showActionSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 8) {
                // Attachment Button
                Button(action: { showActionSheet = true }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .frame(width: 36, height: 36)
                }
                
                // Text Input
                HStack(spacing: 8) {
                    TextField("Message", text: $messageText, axis: .vertical)
                        .focused(isInputFocused)
                        .lineLimit(1...6)
                        .font(.system(size: 16))
                        .padding(.vertical, 10)
                        .padding(.leading, 4)
                    
                    if !messageText.isEmpty {
                        Button(action: onSend) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemBackground))
        .confirmationDialog("Add Attachment", isPresented: $showActionSheet) {
            Button("Photo Library") { onImagePicker() }
            Button("Camera") { onCamera() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
