//
//  ContentView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI

struct HomeView: View {
    
    private let welcomeMessages = [
        "Your AI-powered conversation helper",
        "Ask anything. Build everything.",
        "Smart chats. Real answers."
    ]
    
    //@State private var selectedMessage = ""
    @State private var showSubtitle = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                TypingText(
                    text: "Welcome to Crew!",
                    typingSpeed: 0.08
                )
                .font(.largeTitle)
                .fontWeight(.bold)
                
                Spacer()
                    .frame(height: 10)
                
                NavigationLink(destination: ChatView()) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Open Chat")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.brown)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                Spacer()
            }
        }
    }
}


#Preview {
    HomeView()
}
