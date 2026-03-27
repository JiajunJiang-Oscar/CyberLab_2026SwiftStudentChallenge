//
//  AchievementView.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  One of the two basic pages, this page is used to display the unlocked achievements
//

import Foundation
import SwiftUI
import Combine

struct Achievement: Identifiable {
    let id = UUID()
    let achievementID: String
    let title: String
    let description: String
    let iconName: String
    var isUnlocked: Bool
    let color: Color
}

struct AchievementsView: View {
    @StateObject private var gameProgress = GameProgress.shared
    @State var achievements = achievementsData
    
    private func syncAchievements() {
        for i in 0..<achievements.count {
            let achievementID = achievements[i].achievementID
            
            var nowUnlocked = false
            if achievementID == "medal_part1" {
                nowUnlocked = gameProgress.isCompleted(partIndex: 0)
            } else if achievementID == "medal_part2" {
                nowUnlocked = gameProgress.isCompleted(partIndex: 1)
            } else if achievementID == "medal_part3" {
                nowUnlocked = gameProgress.isCompleted(partIndex: 2)
            } else {
                nowUnlocked = gameProgress.isAchievementUnlocked(achievementID)
            }
            
            achievements[i].isUnlocked = nowUnlocked
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Divider()
                    .padding(.top, 8)
                
                // Achievements Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Achievements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 20) {
                        ForEach(achievements) { achievement in
                            HStack(spacing: 16) {
                                Image(systemName: achievement.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(achievement.isUnlocked ? achievement.color : Color.gray.opacity(0.3))
                                    )
                                    .foregroundColor(.white)
                                    .opacity(achievement.isUnlocked ? 1 : 0.4)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(achievement.title)
                                        .font(.headline)
                                        .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                                    Text(achievement.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(gameProgress.objectWillChange) { _ in
            syncAchievements()
        }
        .onAppear {
            syncAchievements()
        }
    }
}
