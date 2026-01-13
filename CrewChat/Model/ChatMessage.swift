//
//  ChatMessage.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftData

@Model
final class ChatMessage {
    @Attribute(.unique) var id: String
    var message: String
    var type: String // "text" or "file"
    var filePath: String?
    var fileSize: Int?
    var thumbnailPath: String?
    var sender: String // "user" or "agent"
    var timestamp: Int64
    
    init(id: String, message: String, type: String, filePath: String? = nil, fileSize: Int? = nil, thumbnailPath: String? = nil, sender: String, timestamp: Int64) {
        self.id = id
        self.message = message
        self.type = type
        self.filePath = filePath
        self.fileSize = fileSize
        self.thumbnailPath = thumbnailPath
        self.sender = sender
        self.timestamp = timestamp
    }
}
