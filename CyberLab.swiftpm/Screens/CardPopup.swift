//
//  CardPopup.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  This pop-up window is part of the DefenseGameView. When the user clicks the card selection box, this interface will pop up for card selection. All the cards used in this interface (6/Part * 3) are created by Gemini.
//

import SwiftUI

struct CardPopup: View {
    @Binding var isPresented: Bool
    let partIndex: Int
    let cardIndex: Int
    let lockedCards: Set<String>
    let onSelect: (String) -> Bool
    
    @State private var hoveredCard: String? = nil
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    // Dynamic background color
    private var lightBackgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color(red: 0.95, green: 0.95, blue: 0.95)
    }
    
    private var mediumBackgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.12) : Color(red: 0.92, green: 0.92, blue: 0.92)
    }
    
    private var veryLightBackgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.18) : Color(red: 0.98, green: 0.98, blue: 0.98)
    }
    
    // Return the corresponding card list based on the partIndex.
    private var cardList: [String] {
        switch partIndex {
        case 0:
            // Part 1: P1C1 ~ P1C6
            return (1...6).map { "P1C\($0)" }
        case 1:
            // Part 2: P2C1 ~ P2C6
            return (1...6).map { "P2C\($0)" }
        case 2:
            // Part 3: P3C1 ~ P3C6
            return (1...6).map { "P3C\($0)" }
        default:
            return []
        }
    }
    
    var body: some View {
        #if os(macOS)
        macOSLayout
        #else
        iPadOSLayout
        #endif
    }
    
    // MARK: - macOS Layout
    
    private var macOSLayout: some View {
        HStack(spacing: 0) {
            // Left: Card selection area
            VStack(spacing: 0) {
                Text("Choice Your Card")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                
                let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cardList, id: \.self) { name in
                            let isLocked = lockedCards.contains(name)
                            let isHovered = hoveredCard == name
                            
                            Button {
                                if !isLocked {
                                    if onSelect(name) {
                                        isPresented = false
                                    }
                                }
                            } label: {
                                CardImageView(
                                    name: name,
                                    isLocked: isLocked,
                                    isHighlighted: isHovered,
                                    maxWidth: 140,
                                    maxHeight: 200
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isLocked)
                            .onHover { hovering in
                                if hovering && !isLocked {
                                    hoveredCard = name
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
            .frame(maxWidth: .infinity)
            .background(lightBackgroundColor)
            
            Divider()
            
            // Right side: Card description area
            descriptionPanel
                .frame(maxWidth: .infinity)
                .background(mediumBackgroundColor)
        }
        .overlay(alignment: .topTrailing) {
            closeButton
        }
        .frame(minWidth: 900, minHeight: 600)
        .animation(.easeInOut(duration: 0.25), value: hoveredCard)
    }
    
    // MARK: - iPad OS Layout （Click on the card to view the description, and click "Confirm Selection" in the selection box.）
    
    private var iPadOSLayout: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Choice Your Card")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                closeButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(lightBackgroundColor)
            
            Divider()
            
            GeometryReader { geometry in
                let shouldUseHorizontalLayout = geometry.size.width > geometry.size.height
                
                if shouldUseHorizontalLayout {
                    HStack(spacing: 0) {
                        cardGridView(maxCardWidth: 120, maxCardHeight: 180)
                            .frame(width: geometry.size.width * 0.5)
                        
                        Divider()
                        
                        descriptionPanelWithButton
                            .frame(width: geometry.size.width * 0.5)
                    }
                } else {
                    VStack(spacing: 0) {
                        cardGridView(maxCardWidth: 100, maxCardHeight: 150)
                            .frame(height: geometry.size.height * 0.5)
                        
                        Divider()
                        
                        descriptionPanelWithButton
                            .frame(height: geometry.size.height * 0.5)
                    }
                }
            }
        }
        .background(veryLightBackgroundColor)
        .animation(.easeInOut(duration: 0.25), value: hoveredCard)
    }
    
    // MARK: - Shared Components
    
    private var closeButton: some View {
        Button(action: { isPresented = false }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .padding(20)
    }
    
    private func cardGridView(maxCardWidth: CGFloat, maxCardHeight: CGFloat) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(cardList, id: \.self) { name in
                    let isLocked = lockedCards.contains(name)
                    let isSelected = hoveredCard == name
                    
                    Button {
                        if !isLocked {
                            hoveredCard = name
                        }
                    } label: {
                        CardImageView(
                            name: name,
                            isLocked: isLocked,
                            isHighlighted: isSelected,
                            maxWidth: maxCardWidth,
                            maxHeight: maxCardHeight
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isLocked)
                }
            }
            .padding(24)
        }
        .background(lightBackgroundColor)
    }
    // For macOS
    private var descriptionPanel: some View {
        VStack(spacing: 0) {
            Text("Card Description")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 32)
                .padding(.bottom, 24)
            
            if let cardName = hoveredCard, let cardInfo = getCardInfo(partIndex: partIndex, cardID: cardName) {
                CardDescriptionContent(cardInfo: cardInfo)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("Hover over a card to view its description")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
    }
    // For iPadOS
    private var descriptionPanelWithButton: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let cardName = hoveredCard, let cardInfo = getCardInfo(partIndex: partIndex, cardID: cardName) {
                    CardDescriptionContent(cardInfo: cardInfo)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("Tap a card to view its description")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            
            // Confirmation button - Only displayed on iPad
            if let cardName = hoveredCard, !lockedCards.contains(cardName) {
                Divider()
                
                Button(action: {
                    if onSelect(cardName) {
                        isPresented = false
                    }
                }) {
                    Text("Select This Card")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(mediumBackgroundColor)
    }
}

// MARK: - Card Image View Component

struct CardImageView: View {
    let name: String
    let isLocked: Bool
    let isHighlighted: Bool
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    
    var body: some View {
        ZStack {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(isLocked ? 0.4 : 1.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isHighlighted ? Color.blue : (isLocked ? Color.gray : Color.clear),
                            lineWidth: isHighlighted ? 3 : 2
                        )
                )
                .shadow(color: isHighlighted ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            
            if isLocked {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 40, height: 40)
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - The card describes area

struct CardDescriptionContent: View {
    let cardInfo: CardInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text(cardInfo.cardName)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Text("Cost:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.square.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        Text("\(cardInfo.cost)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(8)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(cardInfo.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
