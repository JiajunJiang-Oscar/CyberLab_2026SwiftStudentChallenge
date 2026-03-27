//
//  GameEngineView.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  Main view of the game
//

import SwiftUI

/// Color of the game entry button
private let rippleColor = Color.gray.opacity(0.6)
private let buttonColor = Color.blue

#if os(macOS)
private var platformTitleFont: Font { .title2 }
private var platformLabelFont: Font { .headline }
private var platformIconSize: CGFloat { 50 }
private var platformCheckmarkSize: CGFloat { 28 }
private var platformCheckmarkBgSize: CGFloat { 32 }
private var platformCheckmarkOffset: CGFloat { 25 }
private var platformLockSize: CGFloat { 22 }
private var platformRippleSize: CGFloat { 120 }
#else
private var platformTitleFont: Font { .title }
private var platformLabelFont: Font { .headline }
private var platformIconSize: CGFloat { 60 }
private var platformCheckmarkSize: CGFloat { 24 }
private var platformCheckmarkBgSize: CGFloat { 28 }
private var platformCheckmarkOffset: CGFloat { 22 }
private var platformLockSize: CGFloat { 20 }
private var platformRippleSize: CGFloat { 140 }
#endif


/// Generate random positions on the map
private func getMapPositions(for size: CGSize) -> [CGPoint] {
    let safeMargin: CGFloat = 80
    let positions: [CGPoint] = [
        CGPoint(
            x: size.width * 0.25 + CGFloat.random(in: -30...30),
            y: size.height * 0.3 + CGFloat.random(in: -30...30)
        ),
        CGPoint(
            x: size.width * 0.65 + CGFloat.random(in: -30...30),
            y: size.height * 0.45 + CGFloat.random(in: -30...30)
        ),
        CGPoint(
            x: size.width * 0.4 + CGFloat.random(in: -30...30),
            y: size.height * 0.65 + CGFloat.random(in: -30...30)
        )
    ]
    
    return positions.map { point in
        CGPoint(
            x: max(safeMargin, min(size.width - safeMargin, point.x)),
            y: max(safeMargin, min(size.height - safeMargin, point.y))
        )
    }
}

private struct SubtleTexture: View {
    var color: Color
    var body: some View {
        ZStack {
            Image(systemName: "circle.grid.3x3.fill")
                .resizable()
                .scaledToFill()
                .foregroundColor(color.opacity(0.15))
                .blendMode(.overlay)
                .opacity(0.4)
        }
        .allowsHitTesting(false)
    }
}

/// xPuddle
private struct RippleEffect: View {
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(rippleColor.opacity(0.6), lineWidth: 3)
                .scaleEffect(animationAmount)
                .opacity(2 - animationAmount)
            
            Circle()
                .stroke(rippleColor.opacity(0.4), lineWidth: 2)
                .scaleEffect(animationAmount * 1.2)
                .opacity(1.8 - animationAmount)
            
            Circle()
                .stroke(rippleColor.opacity(0.2), lineWidth: 1)
                .scaleEffect(animationAmount * 1.4)
                .opacity(1.6 - animationAmount)
        }
        .onAppear {
            withAnimation(
                Animation.easeOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
            ) {
                animationAmount = 2
            }
        }
    }
}

struct GameEngineView: View {
    @StateObject private var gameProgress = GameProgress.shared
    @State private var selectedPartIndex: Int? = nil
    @State private var showChatView = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let totalParts = 3
    
    private var backgroundImageName: String {
        colorScheme == .dark ? "BackgroundDark" : "BackgroundLight"
    }
    
    private func defenseCompleted(for index: Int) -> Bool {
        gameProgress.isCompleted(partIndex: index)
    }
    
    private func defenseUnlocked(for index: Int) -> Bool {
        gameProgress.isUnlocked(partIndex: index)
    }

    var body: some View {
        if showChatView, let partIndex = selectedPartIndex {
            ChatView(
                partIndex: partIndex,
                isPresented: $showChatView
            )
        } else {
            mainView
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        GeometryReader { proxy in
            ZStack {
                // Background
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()

                titleBar
                
                // Points in map
                mapPoints(size: CGSize(width: proxy.size.width, height: proxy.size.height - 100))
            }
            // Restart onboarding guide button
            .overlay(alignment: .bottomLeading) {
                #if os(macOS)
                assistantRobot(viewWidth: proxy.size.width)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                #else
                assistantRobot(viewWidth: proxy.size.width)
                    .padding(.leading, 20)
                    .padding(.bottom, 60)
                #endif
            }
            .withInteractiveOnboarding()
            .onAppear {
                checkOnboardingStatus()
            }
        }
    }
    
    // MARK: - Reusable component
    
    /// Top bar
    private var titleBar: some View {
        VStack {
            HStack {
                Spacer()
                Text("Your Defense Missions")
                    .font(platformTitleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                Spacer()
            }
            .padding(.top, 40)
            Spacer()
        }
    }
    
    /// Map punctuation area
    private func mapPoints(size: CGSize) -> some View {
        let positions = getMapPositions(for: size)
        
        return ZStack {
            ForEach(0..<totalParts, id: \.self) { index in
                let unlocked = defenseUnlocked(for: index)
                let completed = defenseCompleted(for: index)
                let position = positions[index]
                
                ZStack {
                    // xPuddle
                    if unlocked && !completed {
                        RippleEffect()
                            .frame(width: platformRippleSize, height: platformRippleSize)
                    }
                    
                    // Mission button
                    partButton(index: index, unlocked: unlocked, completed: completed)
                }
                .position(x: position.x, y: position.y)
            }
        }
    }
    
    /// Mission button
    private func partButton(index: Int, unlocked: Bool, completed: Bool) -> some View {
        let isOnboardingActive = InteractiveOnboardingManager.shared.isActive
        let isClickPart1Step = InteractiveOnboardingManager.shared.currentStep == .clickPart1
        
        return Button(action: {
            handlePartClick(index: index)
        }) {
            VStack(spacing: 10) {
                // symbol
                ZStack {
                    let symbolNames = ["person.fill.questionmark", "person.badge.shield.exclamationmark.fill"]
                    let randomSymbol = symbolNames[index % 2]
                    
                    Image(systemName: randomSymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: platformIconSize, height: platformIconSize)
                        .foregroundColor(unlocked ? buttonColor : Color.gray.opacity(0.6))
                        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                    
                    // Complete symbol
                    if completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: platformCheckmarkSize))
                            .foregroundColor(.green)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: platformCheckmarkBgSize, height: platformCheckmarkBgSize)
                            )
                            .offset(x: platformCheckmarkOffset, y: -platformCheckmarkOffset)
                    }
                    
                    // Locked symbol
                    if !unlocked && !isOnboardingActive {
                        Image(systemName: "lock.fill")
                            .font(.system(size: platformLockSize))
                            .foregroundColor(.white)
                    }
                }
                
                // Random symbol for game enterance
                Text("Mission \(index + 1)")
                    .font(platformLabelFont)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.85))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
            }
        }
        .buttonStyle(.plain)
        .background(
            index == 0 ? GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        InteractiveOnboardingManager.shared.part1Frame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                        InteractiveOnboardingManager.shared.part1Frame = newFrame
                    }
            } : nil
        )
        .disabled(isOnboardingActive && isClickPart1Step && index != 0)
        .disabled(!unlocked && !isOnboardingActive)
        .opacity(isOnboardingActive && isClickPart1Step && index != 0 ? 0.3 : 1.0)
    }
    
    /// Robotoo assistance
    private func assistantRobot(viewWidth: CGFloat) -> some View {
        let robotSize = viewWidth * 0.04
        
        return Button(action: {
            InteractiveOnboardingManager.shared.resetOnboarding()
        }) {
            HStack(alignment: .center, spacing: 12) {
                Image("Assistant2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: robotSize, height: robotSize)
                
                Text("Lost? Tap to review the guide!")
                    .font(.system(size: max(viewWidth * 0.012, 12)))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.blue)
                    .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    

    
    // MARK: - Event Processing
    
    private func handlePartClick(index: Int) {
        // Guided mode inspection
        if InteractiveOnboardingManager.shared.isActive &&
           InteractiveOnboardingManager.shared.currentStep == .clickPart1 {
            guard index == 0 else { return }
            InteractiveOnboardingManager.shared.nextStep()
        }
        
        // Normal process
        guard defenseUnlocked(for: index) || InteractiveOnboardingManager.shared.isActive else { return }
        selectedPartIndex = index
        showChatView = true
    }
    
    private func checkOnboardingStatus() {
        if !InteractiveOnboardingManager.shared.hasCompleted {
            Task { @MainActor in
                InteractiveOnboardingManager.shared.startOnboarding()
            }
        }
    }
}

#if DEBUG
@available(iOS 17, *)
#Preview {
    GameEngineView()
}
#endif
