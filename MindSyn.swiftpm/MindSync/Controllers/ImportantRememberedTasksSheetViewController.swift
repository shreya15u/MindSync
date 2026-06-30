//
//  ImportantRememberedTasksSheetViewController.swift
//  MindSync
//

import UIKit

final class ImportantRememberedTasksSheetViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No tasks are marked as Remember."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private var tasks: [Task] {
        TaskManager.shared.tasks.filter { $0.isRemember && !$0.isCompleted }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Remembered Tasks"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeSheet)
        )

        setupTableView()
        refreshUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }

    @objc private func closeSheet() {
        dismiss(animated: true)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func refreshUI() {
        tableView.reloadData()
        let isEmpty = tasks.isEmpty
        tableView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
}

extension ImportantRememberedTasksSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = tasks[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = task.text
        config.textProperties.numberOfLines = 2
        config.image = UIImage(systemName: "bookmark.fill")
        config.imageProperties.tintColor = .systemBlue
        if let reminderDate = task.reminderDate {
            config.secondaryText = "Reminder: \(Self.dateFormatter.string(from: reminderDate))"
            config.secondaryTextProperties.color = .secondaryLabel
        }
        cell.contentConfiguration = config
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            TaskManager.shared.removeTask(task)
            self?.refreshUI()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
