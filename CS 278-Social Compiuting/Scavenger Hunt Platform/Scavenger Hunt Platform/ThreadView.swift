//
//  ThreadView.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 5/15/24.
//

import SwiftUI
import Foundation

struct ThreadView: View {
    let username: String
    let huntName: String
    @State private var messages = [Message]()
    @State private var inputText = ""
    
    var body: some View {

        VStack {
            List(messages) { message in
                VStack (alignment:.leading, spacing: 5) {
                    Text(message.text)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text(message.username)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                // Text(message.text)
                
                
            }
            
            TextField("Enter a message", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    addNewMessage()
                }
                .submitLabel(.send)
            
            
        }
        .navigationTitle(huntName)
    }
    
    private func addNewMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            messages.append(Message(text: trimmedText, username: username))
            inputText = "" // Clear the input field
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    var text: String
    var username: String
}
