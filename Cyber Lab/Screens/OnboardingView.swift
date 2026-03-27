//
//  OnboardingComponents.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  Beginner's guide tutorial, used to instruct new users on how to use the software
//

import SwiftUI
import Combine

// MARK: - Guiding step definition

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case clickPart1 = 1
    case watchStory = 2
    case selectFirstCard = 3
    case completed = 4
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Cyber Lab!"
        case .clickPart1:
            return "Start Your First Mission"
        case .watchStory:
            return "Learn the Story..."
        case .selectFirstCard:
            return "Choose Your Card!"
        case .completed:
            return "Great Job!"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Hi, I'm Robotoo. I’ll guide you through your first cybersecurity mission. Let’s get started."
        case .clickPart1:
            return "Tap the button to begin your first mission. Once you complete it, the next mission will unlock automatically."
        case .watchStory:
            return "Watch the introductions carefully — they’re important. Then tap Next in the bottom-right corner until they are finished."
        case .selectFirstCard:
            return "Click the card box to choose your cards. Each mission requires 4 cards. Read the descriptions carefully and check the point cost before confirming your selection."
        case .completed:
            return "You've mastered the basics! Select four cards, then tap \"Start Testing\" to put your strategy to the test."
        }
    }
}

// MARK: - Guide Manager

class InteractiveOnboardingManager: ObservableObject {
    static let shared = InteractiveOnboardingManager()
    
    @Published var isActive: Bool
    @Published var currentStep: OnboardingStep
    @Published var part1Frame: CGRect
    @Published var nextButtonFrame: CGRect
    @Published var dialogueFrame: CGRect
    @Published var cardSlotFrame: CGRect
    
    private init() {
        // Initialize all attributes
        self.isActive = false
        self.currentStep = .welcome
        self.part1Frame = .zero
        self.nextButtonFrame = .zero
        self.dialogueFrame = .zero
        self.cardSlotFrame = .zero
    }
    
    var currentHighlightFrames: [CGRect] {
        switch currentStep {
        case .welcome:
            return []
        case .clickPart1:
            return [part1Frame]
        case .watchStory:
            return [dialogueFrame, nextButtonFrame].filter { $0 != .zero }
        case .selectFirstCard:
            return [cardSlotFrame].filter { $0 != .zero }
        case .completed:
            return []
        }
    }
    
    var currentHighlightFrame: CGRect? {
        currentHighlightFrames.first
    }
    
    // Statr Guide
    @MainActor
    func startOnboarding() {
        isActive = true
        currentStep = .welcome
    }
    
    // Next setp
    @MainActor
    func nextStep() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = next
            }
        } else {
            completeOnboarding()
        }
    }
    
    // Finish guide
    @MainActor
    func completeOnboarding() {
        withAnimation {
            isActive = false
        }
        
        // Use the GameProgress tag to guide completion
        Task { @MainActor in
            GameProgress.shared.markInteractiveOnboardingCompleted()
            
            // Unlock achievement
            GameProgress.shared.unlockAchievement("first_start")
        }
    }
    
    // Reset guide
    @MainActor
    func resetOnboarding() {
        GameProgress.shared.resetInteractiveOnboarding()
        startOnboarding()
    }
    
    // Check status
    var hasCompleted: Bool {
        GameProgress.shared.hasCompletedInteractiveOnboarding
    }
}

// MARK: - Mask Layer

struct InteractiveOnboardingOverlay: View {
    @ObservedObject var manager: InteractiveOnboardingManager
    
    @State private var pulseOpacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .color(.black.opacity(0.75))
                    )
                    
                    for frame in manager.currentHighlightFrames {
                        let highlightPath = Path(
                            roundedRect: frame.insetBy(dx: -8, dy: -8),
                            cornerRadius: 12
                        )
                        context.blendMode = .destinationOut
                        context.fill(highlightPath, with: .color(.black))
                    }
                }
                .allowsHitTesting(false)
                
                ForEach(Array(manager.currentHighlightFrames.enumerated()), id: \.offset) { _, frame in
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan, lineWidth: 3)
                        .frame(width: frame.width + 16, height: frame.height + 16)
                        .position(x: frame.midX, y: frame.midY)
                        .shadow(color: .cyan, radius: 10)
                        .opacity(pulseOpacity)
                        .allowsHitTesting(false)
                }
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        pulseOpacity = 0.3
                    }
                }
                
                VStack {
                    if manager.currentStep == .selectFirstCard {
                        OnboardingTipCard(
                            step: manager.currentStep,
                            onNext: handleNext,
                            onSkip: skipOnboarding
                        )
                        .padding(.horizontal, 32)
                        .padding(.top, 60)
                        
                        Spacer()
                    }
                    else if let frame = manager.currentHighlightFrame {
                        if frame.midY > geometry.size.height / 2 {
                            OnboardingTipCard(
                                step: manager.currentStep,
                                onNext: handleNext,
                                onSkip: skipOnboarding
                            )
                            .padding(.horizontal, 32)
                            .padding(.top, 60)
                            
                            Spacer()
                        } else {
                            Spacer()
                            
                            OnboardingTipCard(
                                step: manager.currentStep,
                                onNext: handleNext,
                                onSkip: skipOnboarding
                            )
                            .padding(.horizontal, 32)
                            .padding(.bottom, 60)
                        }
                    } else {
                        Spacer()
                        
                        OnboardingTipCard(
                            step: manager.currentStep,
                            onNext: handleNext,
                            onSkip: skipOnboarding
                        )
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                }
                .allowsHitTesting(true)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
    
    private func handleNext() {
        manager.nextStep()
    }
    
    private func skipOnboarding() {
        manager.completeOnboarding()
    }
}

// MARK: - Guide Card

struct OnboardingTipCard: View {
    let step: OnboardingStep
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Symbol
            Image("Assistant2")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            // Text
            VStack(alignment: .leading, spacing: 12) {
                Text(step.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(step.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Progress bar
                if step != .welcome && step != .completed {
                    HStack(spacing: 6) {
                        ForEach(1...3, id: \.self) { index in
                            Circle()
                                .fill(index <= (step.rawValue) ? Color.cyan : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 4)
                }
                
                if step == .welcome {
                    Button(action: onNext) {
                        HStack(spacing: 6) {
                            Text("Start")
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.cyan)
                        )
                    }
                    .buttonStyle(.plain)
                } else if step == .completed {
                    Button(action: onSkip) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Done")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
    }
}

// MARK: - Obtain View Location

extension View {
    func getFrame(in coordinateSpace: CoordinateSpace = .global, onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: geometry.frame(in: coordinateSpace))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
    }
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - View Extend

extension View {
    /// Add mask layer
    func withInteractiveOnboarding() -> some View {
        self.modifier(InteractiveOnboardingModifier())
    }
}

// Use the ViewModifier to subscribe to ObservableObject correctly
private struct InteractiveOnboardingModifier: ViewModifier {
    @ObservedObject var manager = InteractiveOnboardingManager.shared
    
    func body(content: Content) -> some View {
        content.overlay {
            if manager.isActive {
                InteractiveOnboardingOverlay(
                    manager: manager
                )
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Preview

#Preview("Welcome Step") {
    let manager = InteractiveOnboardingManager.shared
    return ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        InteractiveOnboardingOverlay(
            manager: manager
        )
    }
    .onAppear {
        manager.isActive = true
        manager.currentStep = .welcome
    }
}

#Preview("Highlight Button") {
    let manager = InteractiveOnboardingManager.shared
    return ZStack {
        VStack {
            Spacer()
            
            Button("Part 1") {
                // Action
            }
            .font(.title2)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Spacer()
        }
        
        InteractiveOnboardingOverlay(
            manager: manager
        )
    }
    .onAppear {
        manager.isActive = true
        manager.currentStep = .clickPart1
        manager.part1Frame = CGRect(x: 100, y: 400, width: 200, height: 60)
    }
}
