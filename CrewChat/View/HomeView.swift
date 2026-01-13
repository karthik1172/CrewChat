//
//  ContentView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 13/01/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                Text("Chat Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your AI-powered conversation helper")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: ChatView()) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Open Chat")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
