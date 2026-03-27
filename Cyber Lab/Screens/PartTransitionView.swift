//
//  Cyber_LabApp.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 24/2/26.
//
//  The transition page is displayed between ChatView and DefenseGameView
//

import SwiftUI

struct PartTransitionView: View {
    let partIndex: Int
    let onStart: () -> Void

    private var calendarSymbol: String {
        switch partIndex {
        case 0: return "1.square"
        case 1: return "2.square"
        case 2: return "3.square"
        default: return "1.square"
        }
    }

    private var transitionInfo: PartTransitionInfo {
        getPartTransitionInfo(for: partIndex)
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.18, green: 0.51, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Top symbol
                HStack(alignment: .center, spacing: 32) {
                    Image("Assistant2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)

                    Image(systemName: calendarSymbol)
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)

                // Info card
                VStack(spacing: 20) {
                    // Part text
                    VStack(spacing: 8) {
                        Text(transitionInfo.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        Text(transitionInfo.subtitle)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 8)

                    // Start button
                    Button(action: onStart) {
                        Text("START")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 48)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.18, green: 0.51, blue: 0.95))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                )
                .padding(.horizontal, 28)
            }
        }
    }
}

#Preview {
    PartTransitionView(partIndex: 0, onStart: {})
}
