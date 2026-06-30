//
//  MainTabView.swift
//  MindSync
//

import SwiftUI
import UIKit

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "mic.fill") }

            RootControllerHost { ReminderViewController() }
                .tabItem { Label("Reminders", systemImage: "bell.fill") }
        }
    }
}

private struct RootControllerHost<Content: UIViewController>: UIViewControllerRepresentable {
    let builder: () -> Content

    func makeUIViewController(context: Context) -> UINavigationController {
        let root = builder()
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
