//
//  TaskManagerViewController.swift
//  MindSync
//

import UIKit

final class TaskManagerViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No tasks yet.\nUse Home to dictate and create tasks."
        l.textColor = .secondaryLabel
        l.font = .preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always
        setupTableView()
        TaskManager.shared.taskDidUpdate = { [weak self] in
            self?.refreshUI()
        }
        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
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
    
    private func toggleAndReloadRow(for taskId: UUID, toggle: () -> Void) {
        toggle()
        if let idx = activeTasks.firstIndex(where: { $0.id == taskId }) {
            tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
        }
    }

    private var activeTasks: [Task] {
        TaskManager.shared.tasks.filter { !$0.isCompleted }
    }

    private func refreshUI() {
        tableView.reloadData()
        let isEmpty = activeTasks.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

extension TaskManagerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activeTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as! TaskCell
        let task = activeTasks[indexPath.row]
        cell.configure(with: task)
        cell.onUrgentTapped = { [weak self] in
            self?.toggleAndReloadRow(for: task.id) { TaskManager.shared.toggleUrgent(for: task.id) }
        }
        cell.onImportantTapped = { [weak self] in
            self?.toggleAndReloadRow(for: task.id) { TaskManager.shared.toggleImportant(for: task.id) }
        }
        cell.onRememberTapped = { [weak self] in
            self?.toggleAndReloadRow(for: task.id) { TaskManager.shared.toggleRemember(for: task.id) }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = activeTasks[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            DispatchQueue.main.async {
                TaskManager.shared.removeTask(task)
                completionHandler(true)
            }
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
