//
//  SceneDelegate.swift
//  MindSync
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let hasOnboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasOnboarded {
            window?.rootViewController = MainTabBarController()
        } else {
            let onboarding = OnboardingViewController()
            onboarding.onComplete = { [weak self] in
                self?.transitionToMainApp()
            }
            window?.rootViewController = onboarding
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func transitionToMainApp() {
        guard let window = window else { return }
        let tabBar = MainTabBarController()
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBar
        })
    }
}
