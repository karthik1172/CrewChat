//
//  CrewChatApp.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI
import SwiftData

@main
struct CrewChatApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .tint(.brown)
        }
        .modelContainer(for: ChatMessage.self)
    }
}
