//
//  MainTabBarController.swift
//  MindSync
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
        styleNavigationBar()
    }
    
    private func setupTabs() {
        let home = HomeViewController()
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "mic.fill"), tag: 0)
        let homeNav = UINavigationController(rootViewController: home)
        homeNav.navigationBar.prefersLargeTitles = true
        
        let tasks = TaskManagerViewController()
        tasks.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "checklist"), tag: 1)
        let tasksNav = UINavigationController(rootViewController: tasks)
        tasksNav.navigationBar.prefersLargeTitles = true
        
        let reminders = ReminderViewController()
        reminders.tabBarItem = UITabBarItem(title: "Reminders", image: UIImage(systemName: "bell.fill"), tag: 2)
        let remindersNav = UINavigationController(rootViewController: reminders)
        remindersNav.navigationBar.prefersLargeTitles = true
        
        let saved = SavedViewController()
        saved.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "bookmark.fill"), tag: 3)
        let savedNav = UINavigationController(rootViewController: saved)
        savedNav.navigationBar.prefersLargeTitles = true
        
        viewControllers = [homeNav, tasksNav, remindersNav, savedNav]
    }
    
    private func styleTabBar() {
        let accent = UIColor(named: "AccentColor") ?? .systemBlue
        tabBar.tintColor = accent
        tabBar.unselectedItemTintColor = .secondaryLabel

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.stackedLayoutAppearance.selected.iconColor = accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func styleNavigationBar() {
        let accent = UIColor(named: "AccentColor") ?? .systemBlue
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().tintColor = accent
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
