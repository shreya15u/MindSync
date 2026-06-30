//
//  ReminderViewController.swift
//  MindSync
//

import UIKit

final class ReminderViewController: UIViewController {
    private var urgentReminderHours: Int = 0
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Section indices
    private enum Section: Int, CaseIterable {
        case urgent = 0
        case longTerm = 1
        case monoFocus = 2
        case importantRemembered = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reminders"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always
        setupTableView()
        NotificationService.requestAuthorization { _ in }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Helpers
    
    private var urgentTasks: [Task] { TaskManager.shared.urgentTasks }
    private var longTermTasks: [Task] { TaskManager.shared.tasks.filter { $0.isImportant && !$0.isCompleted } }
    private var focusTasks: [Task] { TaskManager.shared.tasks.filter { !$0.isCompleted } }
    private var importantRememberedTasks: [Task] {
        TaskManager.shared.tasks.filter { $0.isRemember && !$0.isCompleted }
    }
    
    private func showIntervalPicker() {
        let alert = UIAlertController(title: "Reminder Interval", message: "How often should you be reminded?", preferredStyle: .actionSheet)
        let options: [(String, Int)] = [
            ("Off", 0),
            ("Every 1 hour", 1),
            ("Every 2 hours", 2),
            ("Every 3 hours", 3),
            ("Every 4 hours", 4),
            ("Every 6 hours", 6),
            ("Every 8 hours", 8),
            ("Every 12 hours", 12)
        ]
        for (title, hours) in options {
            let action = UIAlertAction(title: title, style: hours == 0 ? .destructive : .default) { [weak self] _ in
                self?.urgentReminderHours = hours
                if hours == 0 {
                    NotificationService.cancelUrgentReminder()
                } else {
                    NotificationService.cancelUrgentReminder()
                    NotificationService.scheduleUrgentReminder(everyHours: hours)
                }
                // Reload the interval row
                let urgentCount = self?.urgentTasks.count ?? 0
                self?.tableView.reloadRows(at: [IndexPath(row: urgentCount, section: Section.urgent.rawValue)], with: .none)
            }
            if hours == urgentReminderHours {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showDatePicker(for task: Task) {
        let vc = ReminderDateViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startMonoFocus(task: Task) {
        let vc = MonoFocusViewController(task: task)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func showImportantRememberedSheet() {
        let sheetContent = ImportantRememberedTasksSheetViewController()
        let nav = UINavigationController(rootViewController: sheetContent)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension ReminderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .urgent: return "Urgent Reminders"
        case .longTerm: return "Important Reminders"
        case .monoFocus: return "MonoFocus Mode"
        case .importantRemembered: return "Remembered Tasks"
        case .none: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .urgent:
            let tasks = urgentTasks
            // Show tasks + "Remind every" settings row if there are tasks, or 1 empty-state row
            return tasks.isEmpty ? 1 : tasks.count + 1
        case .longTerm:
            let tasks = longTermTasks
            return tasks.isEmpty ? 1 : tasks.count
        case .monoFocus:
            let tasks = focusTasks
            return tasks.isEmpty ? 1 : tasks.count
        case .importantRemembered:
            return 1
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        switch Section(rawValue: indexPath.section) {
        case .urgent:
            let tasks = urgentTasks
            if tasks.isEmpty {
                var config = cell.defaultContentConfiguration()
                config.text = "No urgent tasks"
                config.secondaryText = "Mark tasks as Urgent in the Home tab"
                config.textProperties.color = .secondaryLabel
                config.secondaryTextProperties.color = .tertiaryLabel
                config.image = UIImage(systemName: "clock")
                config.imageProperties.tintColor = .systemGray3
                cell.contentConfiguration = config
            } else if indexPath.row < tasks.count {
                // Task row
                let task = tasks[indexPath.row]
                var config = cell.defaultContentConfiguration()
                config.text = task.text
                config.textProperties.numberOfLines = 2
                config.image = UIImage(systemName: "clock.badge.exclamationmark.fill")
                config.imageProperties.tintColor = .systemBlue
                cell.contentConfiguration = config
            } else {
                // "Remind every" settings row
                var config = cell.defaultContentConfiguration()
                config.text = "Remind every"
                config.image = UIImage(systemName: "bell.badge")
                config.imageProperties.tintColor = .systemBlue
                
                config.secondaryText = urgentReminderHours == 0 ? "Off" : "\(urgentReminderHours)h"
                config.secondaryTextProperties.color = .secondaryLabel
                config.prefersSideBySideTextAndSecondaryText = true
                cell.contentConfiguration = config
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
            
        case .longTerm:
            let tasks = longTermTasks
            if tasks.isEmpty {
                var config = cell.defaultContentConfiguration()
                config.text = "No important tasks"
                config.secondaryText = "Mark tasks as Important in the Home tab"
                config.textProperties.color = .secondaryLabel
                config.secondaryTextProperties.color = .tertiaryLabel
                config.image = UIImage(systemName: "exclamationmark.circle")
                config.imageProperties.tintColor = .systemGray3
                cell.contentConfiguration = config
            } else {
                let task = tasks[indexPath.row]
                var config = cell.defaultContentConfiguration()
                config.text = task.text
                config.textProperties.numberOfLines = 2
                config.secondaryText = task.reminderDate != nil ? "Reminder set" : "Set reminder date"
                config.secondaryTextProperties.color = task.reminderDate != nil ? .systemGreen : .systemBlue
                config.image = UIImage(systemName: task.reminderDate != nil ? "bell.fill" : "bell")
                config.imageProperties.tintColor = task.reminderDate != nil ? .systemGreen : .systemBlue
                cell.contentConfiguration = config
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
            
        case .monoFocus:
            let tasks = focusTasks
            if tasks.isEmpty {
                var config = cell.defaultContentConfiguration()
                config.text = "No tasks available"
                config.secondaryText = "Add tasks from the Home tab"
                config.textProperties.color = .secondaryLabel
                config.secondaryTextProperties.color = .tertiaryLabel
                config.image = UIImage(systemName: "moon.stars")
                config.imageProperties.tintColor = .systemGray3
                cell.contentConfiguration = config
            } else {
                let task = tasks[indexPath.row]
                var config = cell.defaultContentConfiguration()
                config.text = task.text
                config.textProperties.numberOfLines = 2
                config.image = UIImage(systemName: "hourglass")
                config.imageProperties.tintColor = .systemBlue
                cell.contentConfiguration = config
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }

        case .importantRemembered:
            let count = importantRememberedTasks.count
            var config = cell.defaultContentConfiguration()
            config.text = "Open Remembered Tasks"
            config.secondaryText = count == 0 ? "No tasks yet" : "\(count) task(s)"
            config.image = UIImage(systemName: "bookmark.square.fill")
            config.imageProperties.tintColor = .systemBlue
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            
        case .none: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .urgent:
            let tasks = urgentTasks
            if !tasks.isEmpty && indexPath.row == tasks.count {
                showIntervalPicker()
            }
        case .longTerm:
            let tasks = longTermTasks
            guard !tasks.isEmpty, indexPath.row < tasks.count else { return }
            showDatePicker(for: tasks[indexPath.row])
        case .monoFocus:
            let tasks = focusTasks
            guard !tasks.isEmpty, indexPath.row < tasks.count else { return }
            startMonoFocus(task: tasks[indexPath.row])
        case .importantRemembered:
            showImportantRememberedSheet()
        case .none: break
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let taskToDelete: Task?

        switch Section(rawValue: indexPath.section) {
        case .urgent:
            let tasks = urgentTasks
            if tasks.isEmpty || indexPath.row >= tasks.count {
                taskToDelete = nil
            } else {
                taskToDelete = tasks[indexPath.row]
            }

        case .longTerm:
            let tasks = longTermTasks
            taskToDelete = tasks.isEmpty ? nil : tasks[indexPath.row]

        case .monoFocus:
            taskToDelete = nil

        case .importantRemembered, .none:
            taskToDelete = nil
        }

        guard let task = taskToDelete else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            TaskManager.shared.removeTask(task)
            self?.tableView.reloadData()
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [delete])
    }
}
