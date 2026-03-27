//
//  AchievementData.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//

import Foundation
import SwiftUI

let achievementsData: [Achievement] = [
    Achievement(
        achievementID: "medal_part1",
        title: "Part 1 Complete",
        description: "Complete Part 1: Physical Layer of Cybersecurity",
        iconName: "shield.lefthalf.filled",
        isUnlocked: false,
        color: .yellow
    ),
    
    Achievement(
        achievementID: "medal_part2",
        title: "Part 2 Complete",
        description: "Complete Part 2: Offensive and Defensive Tactics",
        iconName: "shield.fill",
        isUnlocked: false,
        color: .orange
    ),
    
    Achievement(
        achievementID: "medal_part3",
        title: "Part 3 Complete",
        description: "Complete Part 3: Human Layer of Cybersecurity",
        iconName: "checkmark.shield.fill",
        isUnlocked: false,
        color: .red
    ),
    
    Achievement(
        achievementID: "first_start",
        title: "Emmm... A new beginning?",
        description: "Start the game for the first time",
        iconName: "sparkles",
        isUnlocked: false,
        color: Color(red: 0.6, green: 0.8, blue: 1.0) // 浅蓝色
    ),
    
    Achievement(
        achievementID: "first_fail",
        title: "So close, yet so far.",
        description: "Fail in any Mission",
        iconName: "flame.fill",
        isUnlocked: false,
        color: Color(red: 1.0, green: 0.3, blue: 0.3) // 鲜红色
    ),
    
    Achievement(
        achievementID: "perfect_run",
        title: "Not today, hacker!",
        description: "Finish all missions without dying",
        iconName: "bolt.shield.fill",
        isUnlocked: false,
        color: Color(red: 0.2, green: 0.8, blue: 0.2) // 绿色
    ),
    
    Achievement(
        achievementID: "three_missions",
        title: "Piece of cake!",
        description: "Finish 3 missions",
        iconName: "birthday.cake.fill",
        isUnlocked: false,
        color: Color(red: 1.0, green: 0.6, blue: 0.8) // 粉色
    ),
]


