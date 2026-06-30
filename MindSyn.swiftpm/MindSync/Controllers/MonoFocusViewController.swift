//
//  MonoFocusViewController.swift
//  MindSync
//

import UIKit

final class MonoFocusViewController: UIViewController {
    private let task: Task
    private var timer: Timer?
    private var elapsed: TimeInterval = 0
    
    private let focusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "STAY FOCUSED ON"
        l.font = .preferredFont(forTextStyle: .caption1)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.setContentHuggingPriority(.required, for: .vertical)
        return l
    }()
    
    private let taskLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .title2)
        l.adjustsFontForContentSizeCategory = true
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let elapsedLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "ELAPSED TIME"
        l.font = .preferredFont(forTextStyle: .caption1)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        return l
    }()
    
    private let timerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .monospacedDigitSystemFont(ofSize: 56, weight: .ultraLight)
        l.textAlignment = .center
        l.textColor = .label
        return l
    }()
    
    private let doneButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Mark Complete"
        config.cornerStyle = .capsule
        config.buttonSize = .large
        config.image = UIImage(systemName: "checkmark")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemGreen
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let closeButton: UIButton = {
        let b = UIButton(type: .close)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        taskLabel.text = task.text
        timerLabel.text = "00:00"
        doneButton.addTarget(self, action: #selector(markComplete), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        // Center content stack
        let contentStack = UIStackView(arrangedSubviews: [focusLabel, taskLabel, elapsedLabel, timerLabel])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 8
        contentStack.setCustomSpacing(4, after: focusLabel)
        contentStack.setCustomSpacing(32, after: taskLabel)
        contentStack.setCustomSpacing(4, after: elapsedLabel)
        
        view.addSubview(closeButton)
        view.addSubview(contentStack)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.trailingAnchor),
            
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsed += 1
            let m = Int(self?.elapsed ?? 0) / 60
            let s = Int(self?.elapsed ?? 0) % 60
            self?.timerLabel.text = String(format: "%02d:%02d", m, s)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @objc private func markComplete() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        TaskManager.shared.toggleCompleted(for: task.id)
        dismiss(animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}
