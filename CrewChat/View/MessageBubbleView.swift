//
//  MessageBubbleView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI

struct MessageBubbleView: View {
    let chatMessage: ChatMessage
    let onImageTap: (String) -> Void
    
    var body: some View {
        HStack {
            if chatMessage.sender == "user" {
                Spacer()
            }
            
            VStack(alignment: chatMessage.sender == "user" ? .trailing : .leading, spacing: 4) {
                if chatMessage.type == "text" {
                    Text(chatMessage.message)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(chatMessage.sender == "user" ? Color.blue : Color(.systemGray5))
                        .foregroundColor(chatMessage.sender == "user" ? .white : .primary)
                        .cornerRadius(18)
                } else {
                    // File message
                    VStack(alignment: .leading, spacing: 6) {
                        if let filePath = chatMessage.filePath {
                            ImageMessageView(filePath: filePath, thumbnailPath: chatMessage.thumbnailPath)
                                .onTapGesture {
                                    onImageTap(filePath)
                                }
                        }
                        
                        if !chatMessage.message.isEmpty {
                            Text(chatMessage.message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let fileSize = chatMessage.fileSize {
                            Text(formatFileSize(fileSize))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                    .background(chatMessage.sender == "user" ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Text(formatTimestamp(chatMessage.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: chatMessage.sender == "user" ? .trailing : .leading)
            
            if chatMessage.sender == "agent" {
                Spacer()
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb)
    }
    
    private func formatTimestamp(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let now = Date()
        let calendar = Calendar.current

        let secondsAgo = Int(now.timeIntervalSince(date))

        // 1. Just now (< 1 min)
        if secondsAgo < 60 {
            return "Just now"
        }

        // 2. Minutes ago (< 1 hour)
        let minutesAgo = secondsAgo / 60
        if minutesAgo < 60 {
            return "\(minutesAgo) minute\(minutesAgo == 1 ? "" : "s") ago"
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        // 3. Today
        if calendar.isDateInToday(date) {
            return "Today at \(timeFormatter.string(from: date))"
        }

        // 4. Yesterday
        if calendar.isDateInYesterday(date) {
            return "Yesterday at \(timeFormatter.string(from: date))"
        }

        // 5. Older messages → full date
        let fullFormatter = DateFormatter()
        fullFormatter.dateStyle = .medium
        fullFormatter.timeStyle = .short
        return fullFormatter.string(from: date)
    }
}
