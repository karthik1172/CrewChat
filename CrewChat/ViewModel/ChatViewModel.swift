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

            ChatMessage(id: "msg-012", message: "The second option looks perfect! How do I proceed?", type: "text", sender: "user", timestamp: 1703520480000),
            ChatMessage(id: "msg-013", message: "Great choice! I’ll need passenger details to proceed.", type: "text", sender: "agent", timestamp: 1703520510000),
            ChatMessage(id: "msg-014", message: "Sure. Passenger name: Karthik Rashinkar.", type: "text", sender: "user", timestamp: 1703520570000),
            ChatMessage(id: "msg-015", message: "Thanks! Could you confirm your age and ID proof type?", type: "text", sender: "agent", timestamp: 1703520600000),
            ChatMessage(id: "msg-016", message: "Age 24. ID proof: Aadhaar.", type: "text", sender: "user", timestamp: 1703520660000),
            ChatMessage(id: "msg-017", message: "Perfect. Do you want to add travel insurance?", type: "text", sender: "agent", timestamp: 1703520690000),
            ChatMessage(id: "msg-018", message: "Yes, please add it.", type: "text", sender: "user", timestamp: 1703520750000),
            ChatMessage(id: "msg-019", message: "Insurance added. Total fare comes to ₹8,450.", type: "text", sender: "agent", timestamp: 1703520780000),
            ChatMessage(id: "msg-020", message: "Sounds good. Please proceed with payment.", type: "text", sender: "user", timestamp: 1703520840000),

            ChatMessage(id: "msg-021", message: "Payment link", type: "file",
                        filePath: "https://images.unsplash.com/photo-1556742049-9088bde8c7c5?w=400",
                        fileSize: 212340,
                        thumbnailPath: "https://images.unsplash.com/photo-1556742049-9088bde8c7c5?w=100",
                        sender: "agent",
                        timestamp: 1703520900000),

            ChatMessage(id: "msg-022", message: "Payment completed ✅", type: "text", sender: "user", timestamp: 1703520960000),
            ChatMessage(id: "msg-023", message: "Awesome! Booking is being confirmed.", type: "text", sender: "agent", timestamp: 1703520990000),
            ChatMessage(id: "msg-024", message: "🎉 Your flight is booked successfully!", type: "text", sender: "agent", timestamp: 1703521050000),
            ChatMessage(id: "msg-025", message: "Booking ID: BLR-MUM-2948", type: "text", sender: "agent", timestamp: 1703521080000),
            ChatMessage(id: "msg-026", message: "Can you email me the ticket?", type: "text", sender: "user", timestamp: 1703521140000),
            ChatMessage(id: "msg-027", message: "Sure! Ticket has been sent to your registered email.", type: "text", sender: "agent", timestamp: 1703521170000),
            ChatMessage(id: "msg-028", message: "Anything else I can help you with?", type: "text", sender: "agent", timestamp: 1703521230000),
            ChatMessage(id: "msg-029", message: "No, that’s all. Thanks for the smooth experience!", type: "text", sender: "user", timestamp: 1703521290000),
            ChatMessage(id: "msg-030", message: "You’re welcome 😊 Have a great trip to Mumbai!", type: "text", sender: "agent", timestamp: 1703521320000)
        ]
    }

}
