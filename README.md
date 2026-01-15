# Crew – Chat Message Viewer (SwiftUI)

A SwiftUI-based iOS app that demonstrates a chat interface between a user and an AI agent.
The app supports text and image messages, local persistence, smooth UI interactions, and follows clean MVVM architecture.

## ✨ Features Implemented
### 🏠 Home Screen

* Simple home screen with navigation to the chat view

* Clean and minimal UI

### 💬 Chat Interface

* Chronological message display (oldest → newest)

* Auto-scrolls to the latest message on launch and when a new message is sent

* Distinct message bubbles:
* Formatted timestamps for each message

### 📝 Message Types

Text Messages

Displayed inside chat bubbles

Image/File Messages

Image rendering from local file path or URL

Displays file size below the image

Tap image to view in full-screen with zoom support

### 📤 Message Input

* Text input field with send button

* Send button disabled when input is empty

* Image attachment support via Photo Library & Camera

* Keyboard-aware input bar (moves with keyboard)

### 💾 Local Persistence

* Messages are cached locally

* Cached messages are loaded on app launch

* Seed data is loaded on first launch before cached messages

### 🧠 State Management

* Reactive UI updates using SwiftUI state

* Centralized message handling through ViewModel

* Clean separation of UI, state, and data layers

### 🎨 UI & UX Enhancements

* Smooth message appearance animations

* Long-press gesture to copy text messages

## 🛠 Setup Instructions
1) Clone the repository
```
git clone https://github.com/karthik1172/CrewChat.git
```
2) Open the project in Xcode

3) Select an iOS Simulator or physical device

4) Build and run the project (⌘ + R)

## Requirements

* Xcode 16+

* iOS 18+

# 📸 Screenshots

Long press to Copy

<img width="585" height="1266" alt="Image" src="https://github.com/user-attachments/assets/1b224dfa-d731-42d9-8252-f2dfbb491420" />


Full working demo youtube link: 
https://youtube.com/shorts/pALs7wgrlJo?feature=share
