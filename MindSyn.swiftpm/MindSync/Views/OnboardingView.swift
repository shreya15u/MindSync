//
//  OnboardingView.swift
//  MindSync
//

import SwiftUI

private struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        icon: "mic.fill",
        iconColor: .blue,
        title: "Capture Your Thoughts",
        subtitle: "Speak naturally and MindSync converts your voice into actionable tasks instantly."
    ),
    OnboardingPage(
        icon: "checklist",
        iconColor: .orange,
        title: "Organize & Prioritize",
        subtitle: "Mark tasks as Urgent, Important, or Remember to stay focused on what matters most."
    ),
    OnboardingPage(
        icon: "bell.badge.fill",
        iconColor: .indigo,
        title: "Never Forget",
        subtitle: "Set custom reminders and use MonoFocus mode to get things done, one task at a time."
    )
]

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0

    var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") { complete() }
                        .foregroundStyle(.secondary)
                        .opacity(currentPage == pages.count - 1 ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { i in
                        VStack(spacing: 0) {
                            Spacer()
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(pages[i].iconColor.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                Image(systemName: pages[i].icon)
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundStyle(pages[i].iconColor)
                            }
                            .padding(.bottom, 32)

                            Text(pages[i].title)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)

                            Text(pages[i].subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 14)
                            Spacer()
                            Spacer()
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page control + button
                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.accentColor : Color(uiColor: .systemGray4))
                                .frame(width: i == currentPage ? 20 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    Button(action: handleNext) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(28)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func handleNext() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            complete()
        }
    }

    private func complete() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete()
    }
}
