//
//  OnboardingViewController.swift
//  MindSync
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    private let pages: [(icon: String, iconColor: UIColor, title: String, subtitle: String)] = [
        (
            icon: "mic.fill",
            iconColor: .systemBlue,
            title: "Capture Your Thoughts",
            subtitle: "Speak naturally and MindSync converts your voice into actionable tasks instantly."
        ),
        (
            icon: "checklist",
            iconColor: .systemOrange,
            title: "Organize & Prioritize",
            subtitle: "Mark tasks as Urgent, Important, or Remember to stay focused on what matters most."
        ),
        (
            icon: "bell.badge.fill",
            iconColor: .systemIndigo,
            title: "Never Forget",
            subtitle: "Set custom reminders and use MonoFocus mode to get things done, one task at a time."
        )
    ]
    
    private var currentPage = 0
    
    var onComplete: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
        return sv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = UIColor(named: "AccentColor") ?? .systemIndigo
        pc.pageIndicatorTintColor = UIColor.systemGray4
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Continue"
        config.cornerStyle = .capsule
        config.buttonSize = .large
        config.baseBackgroundColor = UIColor(named: "AccentColor") ?? .systemIndigo
        config.baseForegroundColor = .white
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Skip"
        config.baseForegroundColor = .secondaryLabel
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        nextButton.addAction(UIAction { [weak self] _ in self?.handleNext() }, for: .touchUpInside)
        skipButton.addAction(UIAction { [weak self] _ in self?.completeOnboarding() }, for: .touchUpInside)
        scrollView.delegate = self
        
        setupLayout()
        createPages()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -32),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func createPages() {
        for (index, page) in pages.enumerated() {
            let pageView = createPageView(
                icon: page.icon,
                iconColor: page.iconColor,
                title: page.title,
                subtitle: page.subtitle
            )
            pageView.translatesAutoresizingMaskIntoConstraints = false
            pageView.tag = index
            scrollView.addSubview(pageView)
            
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                pageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                pageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            if index == 0 {
                pageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            } else {
                let previousPage = scrollView.subviews[index - 1]
                pageView.leadingAnchor.constraint(equalTo: previousPage.trailingAnchor).isActive = true
            }
            
            if index == pages.count - 1 {
                pageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }
        }
    }
    
    private func createPageView(icon: String, iconColor: UIColor, title: String, subtitle: String) -> UIView {
        let container = UIView()
        
        // Icon circle background
        let iconBgView = UIView()
        iconBgView.translatesAutoresizingMaskIntoConstraints = false
        iconBgView.backgroundColor = iconColor.withAlphaComponent(0.12)
        iconBgView.layer.cornerRadius = 50
        iconBgView.layer.cornerCurve = .continuous
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .medium))
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .title1).bold()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        container.addSubview(iconBgView)
        iconBgView.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconBgView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconBgView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -80),
            iconBgView.widthAnchor.constraint(equalToConstant: 100),
            iconBgView.heightAnchor.constraint(equalToConstant: 100),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBgView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBgView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconBgView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -40)
        ])
        
        return container
    }
    
    // MARK: - Actions
    
    private func handleNext() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            let offset = CGFloat(currentPage) * scrollView.bounds.width
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            updateUI()
        } else {
            completeOnboarding()
        }
    }
    
    private func updateUI() {
        pageControl.currentPage = currentPage
        
        let isLastPage = currentPage == pages.count - 1
        UIView.animate(withDuration: 0.25) {
            self.skipButton.alpha = isLastPage ? 0 : 1
        }
        
        var config = nextButton.configuration
        config?.title = isLastPage ? "Get Started" : "Continue"
        nextButton.configuration = config
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        onComplete?()
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        currentPage = page
        updateUI()
    }
}

// MARK: - UIFont Extension
private extension UIFont {
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
