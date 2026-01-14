//
//  ContentView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showSubtitle = false
    @State private var didShowTypingAnimation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                if didShowTypingAnimation {
                    Text("Welcome to Crew!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else {
                    TypingText(
                        text: "Welcome to Crew!",
                        typingSpeed: 0.08,
                        onFinished: {
                            didShowTypingAnimation = true
                        }
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)
                }
                
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
