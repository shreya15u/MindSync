//
//  TaskCell.swift
//  MindSync
//

import UIKit

final class TaskCell: UITableViewCell {
    static let reuseId = "TaskCell"
    
    var onUrgentTapped: (() -> Void)?
    var onImportantTapped: (() -> Void)?
    var onRememberTapped: (() -> Void)?
    

    
    private let taskLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        l.numberOfLines = 0
        return l
    }()
    
    private let urgentButton = TaskCell.makeTagButton(title: "Urgent")
    private let importantButton = TaskCell.makeTagButton(title: "Important")
    private let rememberButton = TaskCell.makeTagButton(title: "Remember")
    
    private let tagStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.spacing = 8
        s.distribution = .fillEqually
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private static func makeTagButton(title: String) -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = title
        config.cornerStyle = .capsule
        config.buttonSize = .small
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.preferredFont(forTextStyle: .caption1)
            return out
        }
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }
    
    private func setup() {
        selectionStyle = .none
        contentView.addSubview(taskLabel)
        contentView.addSubview(tagStack)
        tagStack.addArrangedSubview(urgentButton)
        tagStack.addArrangedSubview(importantButton)
        tagStack.addArrangedSubview(rememberButton)
        
        urgentButton.addAction(UIAction { [weak self] _ in self?.onUrgentTapped?() }, for: .touchUpInside)
        importantButton.addAction(UIAction { [weak self] _ in self?.onImportantTapped?() }, for: .touchUpInside)
        rememberButton.addAction(UIAction { [weak self] _ in self?.onRememberTapped?() }, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tagStack.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 10),
            tagStack.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor),
            tagStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tagStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            tagStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
    
    func configure(with task: Task) {
        taskLabel.attributedText = nil
        taskLabel.text = task.text
        taskLabel.textColor = .label
        
        styleTag(urgentButton, active: task.isUrgent, color: .systemRed)
        styleTag(importantButton, active: task.isImportant, color: .systemOrange)
        styleTag(rememberButton, active: task.isRemember, color: .systemBlue)
    }
    
    private func styleTag(_ button: UIButton, active: Bool, color: UIColor) {
        if active {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = color
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.buttonSize = .small
            config.title = button.configuration?.title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = UIFont.preferredFont(forTextStyle: .caption1)
                return out
            }
            button.configuration = config
        } else {
            var config = UIButton.Configuration.tinted()
            config.baseBackgroundColor = color
            config.baseForegroundColor = color
            config.cornerStyle = .capsule
            config.buttonSize = .small
            config.title = button.configuration?.title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = UIFont.preferredFont(forTextStyle: .caption1)
                return out
            }
            button.configuration = config
        }
    }
}
