//
//  Cyber_LabApp.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//

import SwiftUI

@main
struct CyberLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
        }
        #if os(macOS)
        .windowStyle(.automatic)
        #endif
    }
}
