//
//  ShiMonApp.swift
//  ShiMon
//
//  Created by Howard Lee on 2026/1/19.
//

import SwiftUI
import Combine

@main
struct ShiMonApp: App {
    @StateObject private var userManager = UserManager.shared
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingContainerView()
            } else {
                ContentView()
                    .environmentObject(userManager)
                    .task {
                        await userManager.autoLogin()
                    }
            }
        }
    }
}
