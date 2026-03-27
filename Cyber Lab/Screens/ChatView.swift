//
//  ChatView.swift
//  CyberLab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  The Chat view is used to display some plots before different parts start, helping users immerse themselves in the situation and understand the game goal
//

import SwiftUI

struct ChatView: View {
    let partIndex: Int
    @Binding var isPresented: Bool
    
    @StateObject private var gameProgress = GameProgress.shared
    @State private var currentMessageIndex = 0
    @State private var showGameView = false
    @State private var showTransitionView = false
    @State private var showExitConfirmation = false
    @State private var assistantImage: String = "Assistant2"
    @Environment(\.colorScheme) private var colorScheme
    
    // // Dynamic background
    private var backgroundImageName: String {
        colorScheme == .dark ? "BDBlurred" : "BLBlurred"
    }
    
    // Nav background color
    private var navBarBackground: Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    // Different messages for differnt part intro
    var currentDialogues: DialogueSet {
        getDialogues(for: partIndex)
    }

    var dialogueMessages: [String] {
        currentDialogues.bossDialogues
    }
    var messagesToShow: [String] {
        var messages = [currentDialogues.firstMessage]
        messages.append(contentsOf: dialogueMessages.prefix(currentMessageIndex))
        return messages
    }
    var hasMoreMessages: Bool {
        currentMessageIndex < dialogueMessages.count
    }
    
    var body: some View {
        if showGameView {
            DefenseGameView(partIndex: partIndex, isPresented: Binding(
                get: { showGameView },
                set: { newValue in
                    showGameView = newValue
                    if !newValue {
                        isPresented = false
                    }
                }
            ))
        } else if showTransitionView {
            PartTransitionView(partIndex: partIndex) {
                showTransitionView = false
                showGameView = true
            }
        } else {
            chatContentView
        }
    }
    
    private var chatContentView: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Nav bar
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        showExitConfirmation = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back to Home Page")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: 44)
                .background(navBarBackground)
                
                Divider()
                
                // Main message area
                VStack(spacing: 0) {
                    Text(chatViewHintText)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            ForEach(messagesToShow.indices, id: \.self) { index in
                                HStack(alignment: .center, spacing: 0) {
                                    Spacer().frame(width: 16)
                                    
                                    Text(messagesToShow[index])
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color.blue.opacity(0.9),
                                                    Color.blue.opacity(0.7)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(18)
                                        .shadow(color: Color.blue.opacity(0.3), radius: 8, y: 4)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.bottom, 16)
                        
                        VStack(spacing: 0) {
                            HStack(alignment: .bottom, spacing: 12) {
                                Image(assistantImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                    .padding(.leading, 20)
                                    .padding(.bottom, 8)
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                                
                                Spacer()
                            }
                            
                            // Next button
                            HStack {
                                Spacer()
                                
                                Button(action: handleNextButton) {
                                    Text("NEXT")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color.blue,
                                                    Color.blue.opacity(0.8)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: Color.blue.opacity(0.4), radius: 10, y: 5)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 20)
                                .padding(.bottom, 32)
                            }
                        }
                        .background(Color.clear)
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            // ChatView goal
            if InteractiveOnboardingManager.shared.isActive &&
               InteractiveOnboardingManager.shared.currentStep == .watchStory {
                OnboardingTipCard(
                    step: .watchStory,
                    onNext: { },
                    onSkip: { }
                )
                .padding(.horizontal, 32)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay {
            if showExitConfirmation {
                ExitConfirmPopup(isPresented: $showExitConfirmation) {
                    isPresented = false
                }
            }
        }
        .onAppear {
            currentMessageIndex = 0
            showGameView = false
            showTransitionView = false
            assistantImage = ["Assistant2", "Assistant3"].randomElement()!
        }
    }
    
    private func handleNextButton() {
        if hasMoreMessages {
            withAnimation {
                currentMessageIndex += 1
            }
        } else {
            // Proceed to the next step in onboarding
            if InteractiveOnboardingManager.shared.isActive &&
               InteractiveOnboardingManager.shared.currentStep == .watchStory {
                InteractiveOnboardingManager.shared.nextStep()
            }
            
            showTransitionView = true
        }
    }
}

#Preview {
    ChatView(partIndex: 0, isPresented: .constant(true))
}
