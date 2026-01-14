//
//  ChatViewModel.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    func getSeedMessages() -> [ChatMessage] {
        return [
            ChatMessage(id: "msg-001", message: "Hi! I need help booking a flight to Mumbai.", type: "text", sender: "user", timestamp: 1703520000000),
            ChatMessage(id: "msg-002", message: "Hello! I'd be happy to help you book a flight to Mumbai. When are you planning to travel?", type: "text", sender: "agent", timestamp: 1703520030000),
            ChatMessage(id: "msg-003", message: "Next Friday, December 29th.", type: "text", sender: "user", timestamp: 1703520090000),
            ChatMessage(id: "msg-004", message: "Great! And when would you like to return?", type: "text", sender: "agent", timestamp: 1703520120000),
            ChatMessage(id: "msg-005", message: "January 5th. Also, I prefer morning flights.", type: "text", sender: "user", timestamp: 1703520180000),
            ChatMessage(id: "msg-006", message: "Perfect! Let me search for morning flights from your location to Mumbai. Could you also share your departure city?", type: "text", sender: "agent", timestamp: 1703520210000),
            ChatMessage(id: "msg-007", message: "", type: "file", filePath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400", fileSize: 245680, thumbnailPath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=100", sender: "user", timestamp: 1703520300000),
            ChatMessage(id: "msg-008", message: "Thanks for sharing! I can see you prefer IndiGo. Let me find the best options for you.", type: "text", sender: "agent", timestamp: 1703520330000),
            ChatMessage(id: "msg-009", message: "Flight options comparison", type: "file", filePath: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=400", fileSize: 189420, thumbnailPath: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=100", sender: "agent", timestamp: 1703520420000),
            ChatMessage(id: "msg-010", message: "The second option looks perfect! How do I proceed?", type: "text", sender: "user", timestamp: 1703520480000)
        ]
    }
}
