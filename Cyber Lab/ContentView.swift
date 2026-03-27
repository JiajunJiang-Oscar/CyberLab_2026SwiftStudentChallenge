//
//  ContentView.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var gameProgress = GameProgress.shared
    @State private var lastTriggerTime: Date = .distantPast
    @State private var lastFullCompletion: [Int: Bool] = [:]
    @State private var showModal: Bool = false
    @State private var modalMessage: String? = nil
    @State private var shownForPart: Set<Int> = []
    @State private var showAchievementToast = false
    @State private var currentAchievement: AchievementUnlockNotification? = nil
    @State private var achievementQueue: [AchievementUnlockNotification] = []

    private func isPartFullyCompleted(_ index: Int) -> Bool {
        gameProgress.isCompleted(partIndex: index)
    }
    
    private func triggerCelebration(for partIndex: Int) {
        if Date().timeIntervalSince(lastTriggerTime) < 0.5 { return }
        lastTriggerTime = Date()
        modalMessage = "Part \(partIndex + 1) Medal unlocked"
        showModal = true
    }
    
    private func handleAchievementUnlocked(_ achievementID: String) {
        guard let achievement = achievementsData.first(where: { $0.achievementID == achievementID }) else {
            return
        }
        
        let notification = AchievementUnlockNotification(
            achievementID: achievementID,
            title: achievement.title,
            iconName: achievement.iconName,
            color: achievement.color
        )
        
        if !showAchievementToast {
            currentAchievement = notification
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showAchievementToast = true
            }
        } else {
            achievementQueue.append(notification)
        }
    }
    
    private func showNextAchievement() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !achievementQueue.isEmpty {
                currentAchievement = achievementQueue.removeFirst()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showAchievementToast = true
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                GameEngineView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                AchievementsView()
                    .tabItem {
                        Image(systemName: "trophy.fill")
                        Text("Achievements")
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let modalMessage {
                CelebrationPopup(
                    isPresented: $showModal,
                    message: modalMessage,
                    primaryActionTitle: "Start Next Chapter",
                    primaryAction: {
                        NotificationCenter.default.post(name: Notification.Name("jumpToNextPart"), object: nil)
                    }
                )
            }
            
            // Achievement unlocked popup
            if showAchievementToast, let achievement = currentAchievement {
                AchievementUnlockedToast(
                    achievement: achievement,
                    isPresented: $showAchievementToast
                )
                .padding(.bottom, 60)
                .onChange(of: showAchievementToast) { oldValue, newValue in
                    if newValue == false {
                        showNextAchievement()
                    }
                }
            }
        }
        .onAppear {
            // Initialize cached completion state without triggering
            for i in 0..<10 {
                lastFullCompletion[i] = gameProgress.isCompleted(partIndex: i)
            }
        }
        .onReceive(gameProgress.objectWillChange) { _ in
            // Only trigger when a part transitions to fully completed
            for i in 0..<10 {
                let was = lastFullCompletion[i] ?? false
                let now = gameProgress.isCompleted(partIndex: i)
                if now && !was {
                    triggerCelebration(for: i)
                }
                lastFullCompletion[i] = now
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("partFinished"))) { notif in
            guard let idx = notif.object as? Int else { return }
            let defenseDone = gameProgress.isCompleted(partIndex: idx)
            if defenseDone && !shownForPart.contains(idx) {
                modalMessage = "Part \(idx + 1) Medal unlocked"
                showModal = true
                shownForPart.insert(idx)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("achievementUnlocked"))) { notif in
            guard let achievementID = notif.object as? String else { return }
            handleAchievementUnlocked(achievementID)
        }
    }
}

#Preview {
    ContentView()
}
