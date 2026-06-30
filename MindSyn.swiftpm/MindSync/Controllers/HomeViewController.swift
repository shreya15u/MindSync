//
//  HomeViewController.swift
//  MindSync
//

import UIKit

final class HomeViewController: UIViewController, UITextViewDelegate {
    private let speechService = SpeechService()
    private var hasRequestedPermissions = false
    private let accentColor = UIColor(named: "AccentColor") ?? .systemIndigo
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Speak naturally to create tasks"
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let statsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        v.layer.cornerRadius = 12
        v.layer.cornerCurve = .continuous
        return v
    }()
    
    private let statsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .footnote)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .systemIndigo
        l.textAlignment = .center
        return l
    }()

    private let textCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.separator.cgColor
        return v
    }()

    private let textView: UITextView = {
        let v = UITextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .preferredFont(forTextStyle: .body)
        v.adjustsFontForContentSizeCategory = true
        v.backgroundColor = .clear
        v.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        v.isEditable = true
        v.returnKeyType = .default
        return v
    }()
    
    private let micButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(named: "AccentColor") ?? .systemIndigo
        config.baseForegroundColor = .white
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.12
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 10
        return b
    }()
    
    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Tap the mic to start dictation…"
        l.textColor = .placeholderText
        l.font = .preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Ready to record"
        l.font = .preferredFont(forTextStyle: .footnote)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackground
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        feedbackGenerator.prepare()
        setupUI()
        setupSpeechService()
        requestPermissionsIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }
    
    private func updateStats() {
        let total = TaskManager.shared.tasks.count
        let completed = TaskManager.shared.tasks.filter { $0.isCompleted }.count
        let urgent = TaskManager.shared.urgentTasks.count
        
        if total == 0 {
            statsView.isHidden = true
        } else {
            statsView.isHidden = false
            var parts: [String] = []
            parts.append("\(total) task\(total == 1 ? "" : "s")")
            if completed > 0 { parts.append("✓ \(completed) done") }
            if urgent > 0 { parts.append("⚡ \(urgent) urgent") }
            statsLabel.text = parts.joined(separator: "  ·  ")
        }
    }
    
    private func setupUI() {
        view.addSubview(subtitleLabel)
        view.addSubview(statsView)
        statsView.addSubview(statsLabel)
        view.addSubview(textCardView)
        textCardView.addSubview(textView)
        textCardView.addSubview(placeholderLabel)
        view.addSubview(micButton)
        view.addSubview(statusLabel)
        textView.delegate = self
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            statsView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            statsView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            statsView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            statsView.heightAnchor.constraint(equalToConstant: 36),
            
            statsLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            statsLabel.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 12),
            statsLabel.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -12),

            textCardView.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 16),
            textCardView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            textCardView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            textCardView.heightAnchor.constraint(equalToConstant: 200),

            textView.topAnchor.constraint(equalTo: textCardView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textCardView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textCardView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textCardView.bottomAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: textCardView.topAnchor, constant: 18),
            placeholderLabel.leadingAnchor.constraint(equalTo: textCardView.leadingAnchor, constant: 16),
            
            micButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            micButton.topAnchor.constraint(equalTo: textCardView.bottomAnchor, constant: 28),
            micButton.widthAnchor.constraint(equalToConstant: 68),
            micButton.heightAnchor.constraint(equalToConstant: 68),

            statusLabel.topAnchor.constraint(equalTo: micButton.bottomAnchor, constant: 14),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupSpeechService() {
        speechService.onTranscript = { [weak self] text in
            DispatchQueue.main.async {
                self?.textView.text = text
                self?.placeholderLabel.isHidden = !text.isEmpty
            }
        }
        speechService.onFinalTranscript = { [weak self] text in
            DispatchQueue.main.async {
                self?.textView.text = text
                self?.placeholderLabel.isHidden = !text.isEmpty
            }
        }
    }
    
    private func requestPermissionsIfNeeded() {
        guard !hasRequestedPermissions else { return }
        hasRequestedPermissions = true
        speechService.requestPermissions { [weak self] granted in
            if !granted {
                self?.showPermissionAlert()
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permissions Required",
            message: "Please enable Microphone and Speech Recognition in Settings to use voice capture.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func micTapped() {
        feedbackGenerator.impactOccurred()
        if speechService.isRecording {
            stopRecordingAndParse()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        textView.text = ""
        placeholderLabel.isHidden = true
        micButton.configuration?.image = UIImage(systemName: "stop.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        micButton.configuration?.baseBackgroundColor = .systemRed
        statusLabel.text = "Listening…"
        startPulseAnimation()
        speechService.startRecording()
    }
    
    private func stopRecordingAndParse() {
        micButton.configuration?.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        micButton.configuration?.baseBackgroundColor = accentColor
        statusLabel.text = "Ready to record"
        stopPulseAnimation()
        speechService.stopRecording()
        
        let text = textView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let tasks = TaskParser.parse(text: text)
        guard !tasks.isEmpty else { return }
        
        TaskManager.shared.addTasks(tasks)
        updateStats()
        
        let alert = UIAlertController(
            title: "Tasks Created",
            message: "\(tasks.count) task(s) added. Check the Tasks tab.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
    }

    private func startPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1
        pulse.toValue = 1.08
        pulse.duration = 0.9
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        micButton.layer.add(pulse, forKey: "pulse")
    }

    private func stopPulseAnimation() {
        micButton.layer.removeAnimation(forKey: "pulse")
    }
}
