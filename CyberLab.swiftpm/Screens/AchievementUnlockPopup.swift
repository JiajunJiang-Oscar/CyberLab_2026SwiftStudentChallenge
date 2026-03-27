//
//  AchievementUnlockPopup.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  Simple pop-up window, used to notify the achievement unlock.
//

import SwiftUI

struct AchievementUnlockNotification {
    let achievementID: String
    let title: String
    let iconName: String
    let color: Color
}

struct AchievementUnlockedToast: View {
    let achievement: AchievementUnlockNotification
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(8)
                .background(
                    Circle()
                        .fill(achievement.color)
                )
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(achievement.color.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 40)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            // Disappear automatically after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            AchievementUnlockedToast(
                achievement: AchievementUnlockNotification(
                    achievementID: "medal_part1",
                    title: "Part 1 Complete",
                    iconName: "shield.lefthalf.filled",
                    color: .yellow
                ),
                isPresented: .constant(true)
            )
            .padding(.bottom, 60)
        }
    }
}


