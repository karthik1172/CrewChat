//
//  TypingText.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 14/01/26.
//

import SwiftUI

struct TypingText: View {
    let text: String
    let typingSpeed: Double
    let onFinished: () -> Void
    
    @State private var displayedText = ""
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                displayedText = ""
                typeText()
            }
    }
    
    private func typeText() {
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * typingSpeed) {
                displayedText.append(character)
                if index == text.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onFinished()
                    }
                }
            }
        }
    }
}
