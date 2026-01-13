//
//  MessageBubbleView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI
//import UIKit

struct MessageBubbleView: View {
    let chatMessage: ChatMessage
    let onImageTap: (String) -> Void
    @State private var showCopied = false

    var body: some View {
        HStack {
            if chatMessage.sender == "user" {
                Spacer()
            }

            VStack(
                alignment: chatMessage.sender == "user" ? .trailing : .leading,
                spacing: 4
            ) {
                if chatMessage.type == "text" {
                    Text(chatMessage.message)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(chatMessage.sender == "user" ? Color.blue : Color(.systemGray5))
                        .foregroundColor(chatMessage.sender == "user" ? .white : .primary)
                        .cornerRadius(18)

                        // Long press → Copy
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = chatMessage.message
                                showCopied = true
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }

                        // Copied toast
                        .overlay(
                            Group {
                                if showCopied {
                                    Text("Copied")
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.75))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .transition(.opacity)
                                }
                            },
                            alignment: .top
                        )
                        .onChange(of: showCopied) { _, newValue in
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showCopied = false
                                }
                            }
                        }

                } else {
                    // File message
                    VStack(alignment: .leading, spacing: 6) {
                        if let filePath = chatMessage.filePath {
                            ImageMessageView(
                                filePath: filePath,
                                thumbnailPath: chatMessage.thumbnailPath
                            )
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
                    .background(
                        chatMessage.sender == "user"
                        ? Color.blue.opacity(0.1)
                        : Color(.systemGray6)
                    )
                    .cornerRadius(12)
                }

                Text(formatTimestamp(chatMessage.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(
                maxWidth: 280,
                alignment: chatMessage.sender == "user" ? .trailing : .leading
            )

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

        if secondsAgo < 60 {
            return "Just now"
        }

        let minutesAgo = secondsAgo / 60
        if minutesAgo < 60 {
            return "\(minutesAgo) minute\(minutesAgo == 1 ? "" : "s") ago"
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        if calendar.isDateInToday(date) {
            return "Today at \(timeFormatter.string(from: date))"
        }

        if calendar.isDateInYesterday(date) {
            return "Yesterday at \(timeFormatter.string(from: date))"
        }

        let fullFormatter = DateFormatter()
        fullFormatter.dateStyle = .medium
        fullFormatter.timeStyle = .short
        return fullFormatter.string(from: date)
    }
}
