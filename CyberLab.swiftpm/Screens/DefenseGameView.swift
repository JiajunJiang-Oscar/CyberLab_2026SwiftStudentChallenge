//
//  DefenseGameView.swift
//  CyberLab
//
//  Created by Jiajun Jiang on 25/6/25.
//
//  Game interface
//

import SwiftUI

// The fixed "value" (the consumed points) of each card
private let defenseCardCosts: [String: Int] = [
    "P1C1": 50,
    "P1C2": 200,
    "P1C3": 150,
    "P1C4": 350,
    "P1C5": 300,
    "P1C6": 150,
    "P2C1": 100,
    "P2C2": 200,
    "P2C3": 300,
    "P2C4": 300,
    "P2C5": 200,
    "P2C6": 50,
    "P3C1": 300,
    "P3C2": 400,
    "P3C3": 250,
    "P3C4": 150,
    "P3C5": 50,
    "P3C6": 200,
]

struct DefenseGameView: View {
    let partIndex: Int
    @Binding var isPresented: Bool
    @StateObject private var gameProgress = GameProgress.shared
    @State private var showExitConfirmation = false
    @State private var showCardPopup = false
    @State private var selectedCardIndex = 0
    @State private var selectedCards: [String?] = Array(repeating: nil, count: 4)
    @State private var lockedCards: Set<String> = []
    @State private var showInsufficientPointsAlert = false
    @State private var showTestFailed = false
    @State private var wrongCardsForPopup: [String] = [] //
    @State private var showAssistantPopup = false
    @State private var assistantImage: String = ["Assistant2", "Assistant3"].randomElement() ?? "Assistant2"
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundImageName: String {
        colorScheme == .dark ? "GBackgroundDark" : "GBackgroundLight"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let imageAspectRatio: CGFloat = 1766.0 / 1274.0
            let availableHeight = geometry.size.height - 45
            let viewAspectRatio = geometry.size.width / availableHeight
            let imageSize = calculateImageSize(
                containerWidth: geometry.size.width,
                containerHeight: availableHeight,
                imageAspectRatio: imageAspectRatio,
                viewAspectRatio: viewAspectRatio
            )
            
            ZStack(alignment: .top) {
                (colorScheme == .dark ? Color.black : Color.white)
                
                VStack(spacing: 0) {
                    topNavigationBar
                    Divider()
                    
                    GeometryReader { contentGeometry in
                        Image(backgroundImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: contentGeometry.size.width, height: contentGeometry.size.height)
                            .clipped()
                            .overlay(
                                mainGameContent(
                                    imageSize: imageSize,
                                    containerWidth: contentGeometry.size.width,
                                    containerHeight: contentGeometry.size.height
                                )
                            )
                    }
                }
            }
        }
        .sheet(isPresented: $showCardPopup) {
            CardPopup(
                isPresented: $showCardPopup,
                partIndex: partIndex,
                cardIndex: selectedCardIndex,
                lockedCards: lockedCards,
                onSelect: { imageName in
                    let success = handleCardSelection(imageName)
                    if success {
                        showCardPopup = false
                    }
                    return success
                }
            )
        }
        .overlay {
            overlayViews
        }
        // Onboarding guide
        .withInteractiveOnboarding()
        .alert("Not enough points", isPresented: $showInsufficientPointsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your current points are not enough for this card.")
        }
        .onDisappear {
            clearGameState()
        }
        .onAppear {
            assistantImage = ["Assistant2", "Assistant3"].randomElement() ?? "Assistant2"
        }
    }

    private func calculateImageSize(
        containerWidth: CGFloat,
        containerHeight: CGFloat,
        imageAspectRatio: CGFloat,
        viewAspectRatio: CGFloat
    ) -> (width: CGFloat, height: CGFloat) {
        if viewAspectRatio > imageAspectRatio {
            let height = containerHeight
            let width = height * imageAspectRatio
            return (width, height)
        } else {
            let width = containerWidth
            let height = width / imageAspectRatio
            return (width, height)
        }
    }
    
    // MARK: - Top Navigation Bar
    
    private var topNavigationBar: some View {
        HStack {
            Button(action: { showExitConfirmation = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back to Home Page")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Points disply
            pointsDisplay
            
            startTestingButton
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(red: 0.95, green: 0.95, blue: 0.95))
    }
    
    private var pointsDisplay: some View {
        HStack(spacing: 8) {
            Image(systemName: "bitcoinsign.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.yellow)
            Text("\(gameProgress.getPoints(for: partIndex))")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
    
    private var startTestingButton: some View {
        Button(action: handleStartTesting) {
            Text("Start Testing")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Main Game Content
    
    private func mainGameContent(
        imageSize: (width: CGFloat, height: CGFloat),
        containerWidth: CGFloat,
        containerHeight: CGFloat
    ) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                gameArea(imageWidth: containerWidth, imageHeight: containerHeight)
                assistantRobot(imageWidth: containerWidth, imageHeight: containerHeight)
            }
        }
    }
    
    private func gameArea(imageWidth: CGFloat, imageHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: imageHeight * 0.02)
            cardSelectionArea(imageWidth: imageWidth, imageHeight: imageHeight)
                .padding(.top, imageHeight * 0.4)
            Spacer(minLength: imageHeight * 0.22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Card selection box positioning
    private func cardSelectionArea(imageWidth: CGFloat, imageHeight: CGFloat) -> some View {
        let totalWidth = imageWidth * 0.88
        let cardSpacing: CGFloat = imageWidth * 0.012
        let cardWidth = (totalWidth - cardSpacing * 3) / 4
        let cardHeight = cardWidth * 1.05
        
        return HStack(spacing: cardSpacing) {
            ForEach(0..<4, id: \.self) { idx in
                CardSlotView(
                    index: idx,
                    selectedCard: selectedCards[idx],
                    isLocked: selectedCards[idx].map { lockedCards.contains($0) } ?? false,
                    onTap: {
                        handleCardSlotTap(at: idx)
                    }
                )
                .frame(width: cardWidth, height: cardHeight)
                .background(
                    // Capture the position of the first card slot for booting
                    idx == 0 ? GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                InteractiveOnboardingManager.shared.cardSlotFrame = geometry.frame(in: .global)
                            }
                            .onChange(of: geometry.frame(in: .global)) { newFrame in
                                InteractiveOnboardingManager.shared.cardSlotFrame = newFrame
                            }
                    } : nil
                )
                .disabled(
                    InteractiveOnboardingManager.shared.isActive &&
                    InteractiveOnboardingManager.shared.currentStep == .selectFirstCard &&
                    idx != 0
                )
                .opacity(
                    InteractiveOnboardingManager.shared.isActive &&
                    InteractiveOnboardingManager.shared.currentStep == .selectFirstCard &&
                    idx != 0 ? 0.3 : 1.0
                )
            }
        }
        .padding(.horizontal, imageWidth * 0.06)
    }
    
    // MARK: - Assistant Robot
    
    private func assistantRobot(imageWidth: CGFloat, imageHeight: CGFloat) -> some View {
        let leftPadding = imageWidth * 0.02
        let bottomPadding = imageHeight * 0.02
        let robotSize = imageWidth * 0.1
        
        return VStack(alignment: .leading, spacing: 6) {
            if showAssistantPopup {
                assistantPopupBubble
            }

            HStack(alignment: .center, spacing: 8) {
                assistantButton
                    .frame(width: robotSize, height: robotSize)

                Text("Tap me to get tips ~")
                    .font(.system(size: max(imageWidth * 0.011, 9)))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.leading, leftPadding)
        .padding(.bottom, bottomPadding)
    }
    
    private var assistantPopupBubble: some View {
        HStack(spacing: 8) {
            Text(randomAssistantTip(for: partIndex))
                .font(.callout)
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .padding(.bottom, 8)
    }
    
    private var assistantButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showAssistantPopup = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut) {
                    showAssistantPopup = false
                }
            }
        }) {
            Image(assistantImage)
                .resizable()
                .scaledToFit()
                .accessibilityLabel("Assistant")
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Overlay Views
    
    @ViewBuilder
    private var overlayViews: some View {
        if showExitConfirmation {
            ExitConfirmPopup(isPresented: $showExitConfirmation) {
                handleExitConfirm()
            }
        }
        
        if showTestFailed {
            GameFailedPopup(
                isPresented: $showTestFailed,
                partIndex: partIndex,
                wrongCards: wrongCardsForPopup
            ) {
                handleTestFailedConfirm()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleStartTesting() {
        for card in lockedCards {
            gameProgress.addSelectedCard(card, for: partIndex)
        }
        
        // Check whether the current card selection meets the conditions for completing the game.
        if gameProgress.checkWinCondition(for: partIndex) {
            gameProgress.markCompleted(partIndex: partIndex)
            
            // All points of the selected cards will be returned when exiting
            for card in lockedCards {
                let cost = defenseCardCosts[card] ?? 0
                let currentPoints = gameProgress.getPoints(for: partIndex)
                gameProgress.setPoints(currentPoints + cost, for: partIndex)
            }
            
            NotificationCenter.default.post(name: Notification.Name("partFinished"), object: partIndex)
            isPresented = false
        } else {
            // Mark the failure and obtain the error card
            gameProgress.markFailed(partIndex: partIndex)
            wrongCardsForPopup = gameProgress.getWrongCards(for: partIndex)
            showTestFailed = true
        }
    }
    
    private func handleCardSlotTap(at index: Int) {
        if InteractiveOnboardingManager.shared.isActive &&
           InteractiveOnboardingManager.shared.currentStep == .selectFirstCard {
            guard index == 0 else { return }
        }
        
        // If there is already a selected card in the current box, click again to cancel selection and return the points.
        if let cardName = selectedCards[index], lockedCards.contains(cardName) {
            lockedCards.remove(cardName)
            selectedCards[index] = nil
            let cost = defenseCardCosts[cardName] ?? 0
            let currentPoints = gameProgress.getPoints(for: partIndex)
            gameProgress.setPoints(currentPoints + cost, for: partIndex)
        } else {
            // If not select the card yet, click to open the card selection box.
            selectedCardIndex = index
            showCardPopup = true
        }
    }
    
    private func handleCardSelection(_ imageName: String) -> Bool {
        // If the card has already been selected in another position, it is not allowed to select again.
        if lockedCards.contains(imageName) {
            return false
        }
        
        let cost = defenseCardCosts[imageName] ?? 0
        let currentPoints = gameProgress.getPoints(for: partIndex)
        
        if cost > currentPoints {
            showInsufficientPointsAlert = true
            return true
        }
        
        if selectedCardIndex >= 0 && selectedCardIndex < selectedCards.count {
            selectedCards[selectedCardIndex] = imageName
            lockedCards.insert(imageName)
        }
        gameProgress.consumePoints(for: partIndex, cost: cost)
        
        // Guidance mode: After selecting the first card, advance to the next onboarding step
        if InteractiveOnboardingManager.shared.isActive &&
           InteractiveOnboardingManager.shared.currentStep == .selectFirstCard &&
           selectedCardIndex == 0 &&
           lockedCards.count == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                InteractiveOnboardingManager.shared.nextStep()
            }
        }
        
        return true
    }
    
    private func handleTestFailedConfirm() {
        for card in lockedCards {
            let cost = defenseCardCosts[card] ?? 0
            let currentPoints = gameProgress.getPoints(for: partIndex)
            gameProgress.setPoints(currentPoints + cost, for: partIndex)
        }
        clearGameState()
    }
    
    private func handleExitConfirm() {
        // All points of the selected cards will be returned before exiting
        for card in lockedCards {
            let cost = defenseCardCosts[card] ?? 0
            let currentPoints = gameProgress.getPoints(for: partIndex)
            gameProgress.setPoints(currentPoints + cost, for: partIndex)
        }
        clearGameState()
        isPresented = false
    }
    
    private func clearGameState() {
        selectedCards = Array(repeating: nil, count: 4)
        lockedCards.removeAll()
        gameProgress.selectedCards[partIndex] = []
    }
}

// MARK: - Card Slot View Component

struct CardSlotView: View {
    let index: Int
    let selectedCard: String?
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                slotBackground
                
                if let cardName = selectedCard {
                    cardContent(cardName: cardName)
                } else {
                    emptySlotContent
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var slotBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isLocked ? Color.orange.opacity(0.6) : Color.gray.opacity(0.3),
                        lineWidth: isLocked ? 3 : 1
                    )
            )
    }
    
    private func cardContent(cardName: String) -> some View {
        ZStack {
            Image(cardName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .opacity(isLocked ? 0.7 : 1.0)
            
            if isLocked {
                lockIndicator
            }
        }
    }
    
    private var lockIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Circle().fill(Color.white))
                    .padding(12)
            }
            Spacer()
        }
    }
    
    private var emptySlotContent: some View {
        VStack {
            Image(systemName: "plus")
                .font(.largeTitle)
                .foregroundColor(.gray.opacity(0.3))
            Text("Select Card")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    DefenseGameView(partIndex: 0, isPresented: .constant(true))
}
