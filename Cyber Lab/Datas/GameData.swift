//
//  GameData.swift
//  CyberLab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  This file contains all game data including onboarding pages, dialogue messages,
//  card information, and assistant tips.
//

import Foundation

// MARK: - Onboarding Data

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

// MARK: - Dialogue Data

struct DialogueSet {
    let firstMessage: String
    let bossDialogues: [String]
}

struct AssistantTips {
    let partIndex: Int
    let tips: [String]
}

// MARK: - Card Data

struct CardInfo {
    let cardID: String
    let cardName: String
    let description: String
    let cost: Int
}

struct PartCardsInfo {
    let partIndex: Int
    
    // Key: cardID
    let cardsInfo: [String: CardInfo]
}

struct CardErrorInfo {
    let cardID: String
    let cardName: String
    let errorReason: String
}

struct PartCardErrors {
    let partIndex: Int
    let errorInfos: [String: CardErrorInfo]
}

// MARK: - Part 1 Data

let part1Dialogues = DialogueSet(
    firstMessage: "Hello, newcomer, are you ready for your first cybersecurity mission?",
    bossDialogues: [
        "A tech company just purchased a batch of basic security infrastructure.",
        "However, they don't know how to deploy it properly… They need your help.",
        "Help them deploy and test the setup. let s see if it holds against early threats!"
    ]
)

let part1CardsInfo = PartCardsInfo(
    partIndex: 0,
    cardsInfo: [
        "P1C1": CardInfo(
            cardID: "P1C1",
            cardName: "Dual Factor Authencation (2FA)",
            description: "\"Install an additional fingerprint lock outside the door to provide an extra layer of security.\" \n\n An effective method to prevent accounts from being easily accessed involves additional authentication steps. Even if the password is leaked, it would be very difficult for others to directly log into the account. This is a very common practice.",
            cost: 50
        ),
        "P1C2": CardInfo(
            cardID: "P1C2",
            cardName: "Router with Detection",
            description: "\"The intelligent doorbell at the entrance will alert you as soon as any suspicious person approaches.\" \n\n Special router - It is located at the network entrance. Not only does it handle the connection of the network, but it also monitors network traffic and flags abnormal activities. It can detect potential attacks immediately and issue early warnings.",
            cost: 200
        ),
        "P1C3": CardInfo(
            cardID: "P1C3",
            cardName: "Hardware Firewall",
            description: "\"The gates at the entrances and exits of the private parking lot can only be accessed by those who have the corresponding authorization.\" \n\n The hardware firewall is responsible for controlling all the data entering and leaving the network, ensuring that only permitted traffic can pass in and out. As the most fundamental line of defense, it can block many common attacks.",
            cost: 150
        ),
        "P1C4": CardInfo(
            cardID: "P1C4",
            cardName: "Security Personnel",
            description: "\"Hire security guards to guard the computer room.\" \n\n Physical security is also of great importance. This security team ensures that the facilities are not maliciously damaged and helps you protect those areas that do not have digital protection.",
            cost: 350
        ),
        "P1C5": CardInfo(
            cardID: "P1C5",
            cardName: "Traffic Monitoring System",
            description: "\"A more intelligent doorbell than Router with Detection, capable of analyzing the status of strangers\" \n\n The Traffic Monitoring System will quietly record and analyze data transmission. Once any abnormal behavior is detected, it will immediately send out a warning. This enables you to identify potential risks as early as possible.",
            cost: 300
        ),
        "P1C6": CardInfo(
            cardID: "P1C6",
            cardName: "Private Internal Network",
            description: "\"Locking important equipment in an insurance box makes it the safest as no one can access it.\" \n\n Private Internal Network enables your internal systems to be completely isolated from the external network. Although the method is rather simple, it significantly reduces the chances of being attacked, and is a very conservative protection approach.",
            cost: 150
        )
    ]
)

let part1CardErrors = PartCardErrors(
    partIndex: 0,
    errorInfos: [
        "P1C5": CardErrorInfo(
            cardID: "P1C5",
            cardName: "Card 5 - Traffic Monitoring System",
            errorReason: "This card overlaps with Router with Detection, which already monitors traffic and costs less. \n For enterprises, the Traffic Monitoring System will not only increase costs but also bring little value."
        ),
        "P1C6": CardErrorInfo(
            cardID: "P1C6",
            cardName: "Card 6 - Private Internal Network",
            errorReason: "This card may makes external access extremely difficult. \n While it offers strong protection, the trade-off is a heavy loss of flexibility — especially for businesses that rely on external communication."
        )
    ]
)

let part1AssistantTips = AssistantTips(partIndex: 0, tips: [
    "Some defenses may seem strong, but drain more points than they return. Choose wisely",
    "Low cost doesn't mean low impact, especially if you combine the right cards.",
    "Defense is a system, not a wall. Consider synergy between cards.",
    "Remember to read the card description. Is it really suitable for you?"
])

// MARK: - Part 2 Data

let part2Dialogues = DialogueSet(
    firstMessage: "Great job on your last mission!",
    bossDialogues: [
        "This time, another company has requested your expertise to take their cybersecurity to the next level.",
        "They've already got decent infrastructure in place, but their staff seriously lacks cybersecurity awareness.",
        "Time to show them what you re capable of. Let's strengthen their defense together!"
    ]
)

let part2CardsInfo = PartCardsInfo(
    partIndex: 1,
    cardsInfo: [
        "P2C1": CardInfo(
            cardID: "P2C1",
            cardName: "Employee Cybersecurity Training",
            description: "\"Like learning how to spot a scam before it happens.\" \n\n Cybersecurity awareness training helps you and your team recognize phishing emails, suspicious links, and common traps. When you know what to look out for, you're far less likely to fall into a hacker's hands.",
            cost: 100
        ),
        "P2C2": CardInfo(
            cardID: "P2C2",
            cardName: "AI Risk Assessment",
            description: "\"Like having a super-intelligent assistant who reads everything before you do.\" \n\n AI tools can scan huge amounts of system and behavior data to uncover risks before they erupt into attacks. While powerful, they aren't perfect - you gain speed and insight, but might face false alarms along the way.",
            cost: 200
        ),
        "P2C3": CardInfo(
            cardID: "P2C3",
            cardName: "Cybersecurity Drill",
            description: "\"Just like a fire drill helps you prepare for a real fire, a cybersecurity drill gets you ready for real attacks.\" \n\n Through simulated threats, you get to test your responses, fix blind spots, and improve your team's ability to stay calm and take action when danger strikes.",
            cost: 300
        ),
        "P2C4": CardInfo(
            cardID: "P2C4",
            cardName: "Cloud Server",
            description: "\"Like renting a high-security vault from a trusted company — safe, spacious, but not cheap.\" \n\n Storing your data on cloud servers lets you enjoy reliable access, off-site backups, and strong protection. But the more you use, the more it costs - balancing convenience and budget is key.",
            cost: 300
        ),
        "P2C5": CardInfo(
            cardID: "P2C5",
            cardName: "Cybersecurity Specialist",
            description: "\"Imagine having a pro bodyguard who knows exactly where and how attacks might happen.\" \n\n A specialist brings expert eyes to your system, helping you spot weaknesses early and choose the right defense — something tools alone can't always do.",
            cost: 200
        ),
        "P2C6": CardInfo(
            cardID: "P2C6",
            cardName: "Data Hard Copy",
            description: "\"Like keeping a handwritten backup of your most important secrets in a locked drawer.\" \n\n Storing critical information offline avoids risks from hacking and digital leaks. It's old-school, but when done right, can be one of the safest last lines of defense.",
            cost: 50
        )
    ]
)

let part2CardErrors = PartCardErrors(
    partIndex: 1,
    errorInfos: [
        "P2C2": CardErrorInfo(
            cardID: "P2C2",
            cardName: "Card 2 - AI Risk Assessment",
            errorReason: "AI-driven systems may speed up detection, but false positives can waste analyst time and drain human resources. \n  Worse, integrating AI too deeply may leak sensitive details about internal defense architecture if not properly isolated."
        ),
        "P2C4": CardErrorInfo(
            cardID: "P2C4",
            cardName: "Card 4 - Cloud Server",
            errorReason: "Cloud services do offer flexibility, but they introduce new risks — especially around data sovereignty, shared responsibility, and potential exposure if misconfigured. \n For organizations without proper cloud governance, this may open more doors than it closes."
        )
    ]
)

let part2AssistantTips = AssistantTips(partIndex: 1, tips: [
    "A high-cost solution without coverage may leave gaps where attackers slip through.",
    "Sometimes, a simple way can save you from a total loss.",
    "Don t fall for shiny tools. Check how well they really defend."
])

// MARK: - Part 3 Data

let part3Dialogues = DialogueSet(
    firstMessage: "It's time for your final mission…",
    bossDialogues: [
        "This company has faced multiple attacks recently. The threats are evolving, and we can't rely on hardware alone.",
        "They need a software-centric security strategy that leaves no gap uncovered.",
        "Make smart choices, optimize resources — this time, the margin for error is minimal."
    ]
)

let part3CardsInfo = PartCardsInfo(
    partIndex: 2,
    cardsInfo: [
        "P3C1": CardInfo(
            cardID: "P3C1",
            cardName: "Intrusion Detection System",
            description: "\"A watchtower on the wall, always scanning for any strange movements.\" \n\n This system silently monitors traffic inside your network and sounds the alarm when it sees something suspicious. It doesn't block intrusions itself, but gives you a precious head start to react in time.",
            cost: 300
        ),
        "P3C2": CardInfo(
            cardID: "P3C2",
            cardName: "SIEM Platform",
            description: "\"Like a command center collecting reports from all departments and piecing together the big picture.\" \n\n The Security Information and Event Management (SIEM) platform gathers logs from different sources, finds connections between hidden clues, and helps uncover stealthy threats. Powerful - but can be expensive and needs careful setup.",
            cost: 400
        ),
        "P3C3": CardInfo(
            cardID: "P3C3",
            cardName: "Deception Technology (Honeypots)",
            description: "\"A fake treasure chest placed to trick thieves.\" \n\n This decoy system lures attackers into a trap so you can watch how they behave - without risking your real systems. A clever way to confuse intruders and study their next moves.",
            cost: 250
        ),
        "P3C4": CardInfo(
            cardID: "P3C4",
            cardName: "VPN Gateway",
            description: "\"A private tunnel built just for you, shielding your journey from curious eyes.\" \n\n A VPN allows secure remote access by encrypting data and hiding it from outsiders. Useful for teams working from different locations - but only if properly set up.",
            cost: 150
        ),
        "P3C5": CardInfo(
            cardID: "P3C5",
            cardName: "Zero Trust Policy",
            description: "\"Even familiar faces must show their ID every time.\" \n\n This policy means nothing is trusted automatically—not users, devices, or apps. Everything must prove it belongs, every time. It's a strict mindset, but keeps things tight and safe.",
            cost: 200
        ),
        "P3C6": CardInfo(
            cardID: "P3C6",
            cardName: "Periodic Security Audits",
            description: "\"Like regular health\" checkups for your network's immune system. \n\n These audits help you spot weaknesses before attackers do. Regular reviews keep you ahead of trouble - though they do take time and resources.",
            cost: 100
        )
    ]
)

let part3CardErrors = PartCardErrors(
    partIndex: 2,
    errorInfos: [
        "P3C2": CardErrorInfo(
            cardID: "P3C2",
            cardName: "Card 2 - SIEM Platform",
            errorReason: "SIEM (Security Information and Event Management) platforms are powerful but often come with high costs and complexity. \n For this scenario, the investment outweighs the value, making it a poor fit under limited resources."
        ),
        "P3C4": CardErrorInfo(
            cardID: "P3C4",
            cardName: "Card 4 - VPN Gateway",
            errorReason: "While VPNs are great for remote access, this scenario does not involve remote teams or external staff. \n Adding a VPN here introduces unnecessary complexity without much security gain."
        )
    ]
)

let part3AssistantTips = AssistantTips(partIndex: 2, tips: [
    "Big platforms may sound impressive — but do they always deliver for the cost",
    "Some systems raise alarms; others quietly watch and record. Which do you trust more?",
    "Think in layers: detection, deception, and regular checkups often work best together."
])

// MARK: - Data Access Functions

private let cardsInfoRegistry: [Int: PartCardsInfo] = [
    0: part1CardsInfo,
    1: part2CardsInfo,
    2: part3CardsInfo
]

/// Obtain card information based on partIndex and cardID
func getCardInfo(partIndex: Int, cardID: String) -> CardInfo? {
    return cardsInfoRegistry[partIndex]?.cardsInfo[cardID]
}

func getAllCardsInfo(for partIndex: Int) -> [String: CardInfo] {
    return cardsInfoRegistry[partIndex]?.cardsInfo ?? [:]
}

private let cardErrorsRegistry: [Int: PartCardErrors] = [
    0: part1CardErrors,
    1: part2CardErrors,
    2: part3CardErrors
]

func getCardErrorInfo(partIndex: Int, cardID: String) -> CardErrorInfo? {
    return cardErrorsRegistry[partIndex]?.errorInfos[cardID]
}

func getAllCardErrors(for partIndex: Int) -> [String: CardErrorInfo] {
    return cardErrorsRegistry[partIndex]?.errorInfos ?? [:]
}

// Dialogue data registry
func getDialogues(for partIndex: Int) -> DialogueSet {
    switch partIndex {
    case 0:
        return part1Dialogues
    case 1:
        return part2Dialogues
    case 2:
        return part3Dialogues
    default:
        return part1Dialogues
    }
}

private let assistantTipsRegistry: [Int: AssistantTips] = [
    0: part1AssistantTips,
    1: part2AssistantTips,
    2: part3AssistantTips
]

func randomAssistantTip(for partIndex: Int) -> String {
    if let tips = assistantTipsRegistry[partIndex]?.tips, let tip = tips.randomElement() {
        return tip
    }
    return "Remember to read the card description. Is it really suitable for you?"
}

// MARK: - UI Text Constants

let exitConfirmationMessage = "Quit the game? Your progress won't be saved."
let exitButtonNotNow = "Not Now"
let exitButtonSure = "Sure"
let chatViewHintText = "Tip: Read through all the dialogue carefully before you start."

// MARK: - Part Transition Data

struct PartTransitionInfo {
    let title: String
    let subtitle: String
}

let part1TransitionInfo = PartTransitionInfo(
    title: "Part 1: Building Core Infrastructure",
    subtitle: "You need to choose 4 cards in total"
)

let part2TransitionInfo = PartTransitionInfo(
    title: "Part 2: Cultivating Security Awareness",
    subtitle: "You need to choose 4 cards in total"
)

let part3TransitionInfo = PartTransitionInfo(
    title: "Part 3: Implementing Proactive Defense",
    subtitle: "You need to choose 4 cards in total"
)

func getPartTransitionInfo(for partIndex: Int) -> PartTransitionInfo {
    switch partIndex {
    case 0: return part1TransitionInfo
    case 1: return part2TransitionInfo
    case 2: return part3TransitionInfo
    default: return part1TransitionInfo
    }
}
