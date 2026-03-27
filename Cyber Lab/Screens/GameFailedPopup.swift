//
//  GameFailedPopup.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  The purpose of this page is to provide the reasons for incorrect card selections and to restart the game.
//

import SwiftUI

struct GameFailedPopup: View {
    @Binding var isPresented: Bool
    let partIndex: Int
    let wrongCards: [String]
    let onConfirm: () -> Void
    
    // Compute correct and wrong counts from GameProgress
    private var requiredCards: Set<String> {
        switch partIndex {
        case 0: return ["P1C1", "P1C2", "P1C3", "P1C4"]
        case 1: return ["P2C1", "P2C3", "P2C5", "P2C6"]
        case 2: return ["P3C1", "P3C3", "P3C5", "P3C6"]
        default: return []
        }
    }
    
    private var selectedCards: Set<String> {
        GameProgress.shared.getSelectedCards(for: partIndex)
    }
    
    private var correctCount: Int {
        selectedCards.filter { requiredCards.contains($0) }.count
    }
    
    private var wrongCount: Int {
        wrongCards.count
    }
    
    private var totalRequired: Int {
        requiredCards.count
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Split popup container
            HStack(spacing: 0) {
                
                // MARK: Left Panel — Status
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "xmark.octagon.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.red)
                    
                    Text("Test Failed")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Card stats
                    VStack(spacing: 14) {
                        StatRow(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            label: "Correct Cards",
                            value: "\(correctCount) / \(totalRequired)"
                        )
                        StatRow(
                            icon: "xmark.circle.fill",
                            iconColor: .red,
                            label: "Incorrect Cards",
                            value: "\(wrongCount)"
                        )
                    }
                    .padding(.horizontal, 28)
                    
                    if wrongCards.isEmpty {
                        Text("You didn't select enough correct cards. Review your choices and try again.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                    
                    Spacer()
                }
                .frame(width: 240)
                .frame(maxHeight: .infinity)
                .background(leftPanelBackground)
                
                // Divider line
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 1)
                
                // MARK: Right Panel — Wrong Cards List
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Incorrect Cards")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("Review the cards below before retrying.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    if wrongCards.isEmpty {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green.opacity(0.7))
                                Text("No incorrect cards selected.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(wrongCards, id: \.self) { cardID in
                                    if let errorInfo = getCardErrorInfo(partIndex: partIndex, cardID: cardID) {
                                        WrongCardRow(errorInfo: errorInfo)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                        }
                        .frame(maxHeight: 280)
                    }
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Try Again button at the bottom of the right panel
                    Button(action: {
                        onConfirm()
                        isPresented = false
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Try Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .frame(width: 320)
                .frame(maxHeight: .infinity)
                .background(rightPanelBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 12)
            .fixedSize(horizontal: true, vertical: true)
        }
    }
    
    private var leftPanelBackground: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(UIColor.systemBackground)
        #endif
    }
    
    private var rightPanelBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 18))
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Display the erroneous card
struct WrongCardRow: View {
    let errorInfo: CardErrorInfo
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(errorInfo.cardID)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    
                    Text(errorInfo.cardName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                Text(errorInfo.errorReason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    GameFailedPopup(
        isPresented: .constant(true),
        partIndex: 0,
        wrongCards: ["P1C5", "P1C6"]
    ) {
        print("Confirmed")
    }
}
