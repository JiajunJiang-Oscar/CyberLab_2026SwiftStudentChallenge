//
//  GameProgress.swift
//  CyberLab
//
//  Created by 姜嘉骏 on 25/6/25.
//
//  Game progress management: Track the completion status of the defense mode for each Part
//

import Foundation
import Combine

@MainActor
class GameProgress: ObservableObject {
    static let shared = GameProgress()
    private let partProgressKey = "partProgress"
    private let partFailuresKey = "partFailures"
    private let pointsKey = "points"
    private let selectedCardsKey = "selectedCards"
    private let unlockedAchievementsKey = "unlockedAchievements"
    private let hasGameStartedKey = "hasGameStarted"
    private let hasCompletedInteractiveOnboardingKey = "hasCompletedInteractiveOnboarding"
    
    // Store the completion status of each Part
    @Published var partProgress: [Int: Bool] = [:] {
        didSet { savePartProgress() }
    }
    
    // Store the failure status of each Part
    @Published var partFailures: [Int: Bool] = [:] {
        didSet { savePartFailures() }
    }
    
    // Points
    @Published var points: [Int: Int] = [:] {
        didSet { savePoints() }
    }
    
    // Cards chosied
    @Published var selectedCards: [Int: Set<String>] = [:] {
        didSet { saveSelectedCards() }
    }
    
    // Store the unlocked achievement ID
    @Published var unlockedAchievements: Set<String> = [] {
        didSet { saveUnlockedAchievements() }
    }
    
    @Published var hasGameStarted: Bool = false {
        didSet { UserDefaults.standard.set(hasGameStarted, forKey: hasGameStartedKey) }
    }
    
    // Finish onboarding guide or not
    @Published var hasCompletedInteractiveOnboarding: Bool = false {
        didSet { UserDefaults.standard.set(hasCompletedInteractiveOnboarding, forKey: hasCompletedInteractiveOnboardingKey) }
    }
    
    private init() {
        loadAllData()
        
        // Part 1 always unlocked
        if partProgress.isEmpty {
            partProgress[0] = false
        }
    }
    
    // MARK: - Persistent Storage
    
    private func loadAllData() {
        if let data = UserDefaults.standard.data(forKey: partProgressKey),
           let decoded = try? JSONDecoder().decode([Int: Bool].self, from: data) {
            partProgress = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: partFailuresKey),
           let decoded = try? JSONDecoder().decode([Int: Bool].self, from: data) {
            partFailures = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: pointsKey),
           let decoded = try? JSONDecoder().decode([Int: Int].self, from: data) {
            points = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: selectedCardsKey),
           let decoded = try? JSONDecoder().decode([Int: [String]].self, from: data) {
            selectedCards = decoded.mapValues { Set($0) }
        }
        
        if let data = UserDefaults.standard.data(forKey: unlockedAchievementsKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            unlockedAchievements = Set(decoded)
        }
        
        hasGameStarted = UserDefaults.standard.bool(forKey: hasGameStartedKey)
        
        hasCompletedInteractiveOnboarding = UserDefaults.standard.bool(forKey: hasCompletedInteractiveOnboardingKey)
    }
    
    private func savePartProgress() {
        if let encoded = try? JSONEncoder().encode(partProgress) {
            UserDefaults.standard.set(encoded, forKey: partProgressKey)
        }
    }
    
    private func savePartFailures() {
        if let encoded = try? JSONEncoder().encode(partFailures) {
            UserDefaults.standard.set(encoded, forKey: partFailuresKey)
        }
    }
    
    private func savePoints() {
        if let encoded = try? JSONEncoder().encode(points) {
            UserDefaults.standard.set(encoded, forKey: pointsKey)
        }
    }
    
    private func saveSelectedCards() {
        let arrayDict = selectedCards.mapValues { Array($0) }
        if let encoded = try? JSONEncoder().encode(arrayDict) {
            UserDefaults.standard.set(encoded, forKey: selectedCardsKey)
        }
    }
    
    private func saveUnlockedAchievements() {
        let array = Array(unlockedAchievements)
        if let encoded = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(encoded, forKey: unlockedAchievementsKey)
        }
    }
    
    // MARK: - Achievemnet Management
    
    /// Unlock achievement
    func unlockAchievement(_ achievementID: String) {
        if !unlockedAchievements.contains(achievementID) {
            unlockedAchievements.insert(achievementID)
            
            // Send notice when achievemrnt unlocked
            NotificationCenter.default.post(
                name: Notification.Name("achievementUnlocked"),
                object: achievementID
            )
            
            objectWillChange.send()
        }
    }
    
    /// Check unlock status
    func isAchievementUnlocked(_ achievementID: String) -> Bool {
        return unlockedAchievements.contains(achievementID)
    }
    
    func markGameStarted() {
        hasGameStarted = true
    }
    
    private func checkThreeMissionsAchievement() {
        let completedCount = partProgress.values.filter { $0 }.count
        if completedCount >= 3 {
            unlockAchievement("three_missions") // "Pice of cake!"
        }
    }
    
    private func checkPerfectCompletionAchievement() {
        if isPerfectCompletion(totalParts: 3) {
            unlockAchievement("perfect_run") // "Not today, hacker!"
        }
    }
    
    // MARK: - Onboarding Management
    
    /// Mark as unlocked
    func markInteractiveOnboardingCompleted() {
        hasCompletedInteractiveOnboarding = true
    }
    
    /// Reset
    func resetInteractiveOnboarding() {
        hasCompletedInteractiveOnboarding = false
    }
    
    // MARK: - Card Selection Management
    
    /// Add the selected cards
    func addSelectedCard(_ cardID: String, for partIndex: Int) {
        if selectedCards[partIndex] == nil {
            selectedCards[partIndex] = []
        }
        selectedCards[partIndex]?.insert(cardID)
    }
    
    /// Get the selected card
    func getSelectedCards(for partIndex: Int) -> Set<String> {
        return selectedCards[partIndex] ?? []
    }
    
    /// Check whether a certain card has been selected
    func isCardSelected(_ cardID: String, for partIndex: Int) -> Bool {
        return selectedCards[partIndex]?.contains(cardID) ?? false
    }
    
    // MARK: - Customs Clearance Condition Inspection
    
    /// The pass card requirements for each Part
    private func getRequiredCards(for partIndex: Int) -> Set<String> {
        switch partIndex {
        case 0:
            return ["P1C1", "P1C2", "P1C3", "P1C4"]
        case 1:
            return ["P2C1", "P2C3", "P2C5", "P2C6"]
        case 2:
            return ["P3C1", "P3C3", "P3C5", "P3C6"]
        default:
            return []
        }
    }
    
    // Check Parts
    func isUnlocked(partIndex: Int) -> Bool {
        if partIndex == 0 {
            return true
        }
        
        guard let previousCompleted = partProgress[partIndex - 1] else {
            return false
        }
        return previousCompleted
    }

    func markCompleted(partIndex: Int) {
        partProgress[partIndex] = true
        checkThreeMissionsAchievement()
        checkPerfectCompletionAchievement()
    }
    
    func isCompleted(partIndex: Int) -> Bool {
        return partProgress[partIndex] ?? false
    }
    
    
    /// Check part meets the clearance conditions
    func checkWinCondition(for partIndex: Int) -> Bool {
        let requiredCards = getRequiredCards(for: partIndex)
        let selected = selectedCards[partIndex] ?? []
        return requiredCards.isSubset(of: selected)
    }
    
    /// Obtain error cards
    func getWrongCards(for partIndex: Int) -> [String] {
        let requiredCards = getRequiredCards(for: partIndex)
        let selected = selectedCards[partIndex] ?? []
        let wrongCards = selected.filter { !requiredCards.contains($0) }
        return Array(wrongCards).sorted()
    }
    
    /// Calcuate the number of correct cards and incorrtect cards
    func getMissingCards(for partIndex: Int) -> [String] {
        let requiredCards = getRequiredCards(for: partIndex)
        let selected = selectedCards[partIndex] ?? []
        let missingCards = requiredCards.filter { !selected.contains($0) }
        return Array(missingCards).sorted()
    }
    

    // MARK: - Part Failed Management
    
    /// Mark part as failed
    func markFailed(partIndex: Int) {
        partFailures[partIndex] = true
        unlockAchievement("first_fail") // "So close, yet so far."
    }

    func hasFailed(partIndex: Int) -> Bool {
        return partFailures[partIndex] ?? false
    }
    
    func hasAnyFailure() -> Bool {
        return partFailures.values.contains(true)
    }
    
    /// Check if all parts have been completed without any failures (perfect clearance)
    func isPerfectCompletion(totalParts: Int) -> Bool {
        for i in 0..<totalParts {
            if !isCompleted(partIndex: i) {
                return false
            }
        }
        return !hasAnyFailure()
    }
    
    // MARK: - Points Management
    
    private func defaultPoints(for partIndex: Int) -> Int {
        switch partIndex {
        case 0:
            return 750
            
        case 1:
            return 650
            
        case 2:
            return 800
            
        default:
            return 1000
        }
    }
    
    func setPoints(_ value: Int, for partIndex: Int) {
        points[partIndex] = value
    }
    
    func getPoints(for partIndex: Int) -> Int {
        return points[partIndex] ?? defaultPoints(for: partIndex)
    }
    
    /// Points are consumed when choosing cards
    func consumePoints(for partIndex: Int, cost: Int) {
        let current = points[partIndex] ?? defaultPoints(for: partIndex)
        let newValue = max(0, current - max(0, cost))
        points[partIndex] = newValue
    }
    
    /// Return the points
    func refundPoints(for partIndex: Int, amount: Int) {
        let current = points[partIndex] ?? defaultPoints(for: partIndex)
        points[partIndex] = current + amount
    }
    
    /// Reset points
    func resetPoints(for partIndex: Int) {
        points[partIndex] = defaultPoints(for: partIndex)
    }
}
