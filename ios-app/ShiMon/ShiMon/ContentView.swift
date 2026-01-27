//
//  ContentView.swift
//  ShiMon
//
//  Created by Howard Lee on 2026/1/19.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        Group {
            if userManager.isLoading {
                LoadingView()
            } else if userManager.isAuthenticated {
                MainTabView()
            } else {
                AuthErrorView()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(hex: "#F8F9FA")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: "#4FACFE"))
                
                Text("正在驗證...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#666666"))
            }
        }
    }
}

struct AuthErrorView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        ZStack {
            Color(hex: "#F8F9FA")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#FF6B6B"))
                
                Text("驗證失敗")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                
                Text("無法連接到伺服器\n請檢查網路連線")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Task {
                        await userManager.reAuthenticate()
                    }
                }) {
                    Text("重試")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4FACFE"), Color(hex: "#00F2FE")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                }
                .padding(.top, 16)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("打卡", systemImage: "checkmark.circle.fill")
                }
            
            ContactsView()
                .tabItem {
                    Label("聯絡人", systemImage: "person.2.fill")
                }
            
            MessageView()
                .tabItem {
                    Label("訊息", systemImage: "envelope.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
    }
}
