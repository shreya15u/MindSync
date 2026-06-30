//
//  SavedViewController.swift
//  MindSync
//

import UIKit

final class SavedViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No remembered tasks.\nMark tasks as Remember in the Tasks tab."
        l.textColor = .secondaryLabel
        l.font = .preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Remember"
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
        let isEmpty = TaskManager.shared.rememberTasks.isEmpty
        tableView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
}

extension SavedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TaskManager.shared.rememberTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = TaskManager.shared.rememberTasks[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = task.text
        config.textProperties.numberOfLines = 0
        config.textProperties.font = .preferredFont(forTextStyle: .body)
        config.textProperties.color = .label
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        config.image = UIImage(systemName: "bookmark.fill", withConfiguration: symbolConfig)
        config.imageProperties.tintColor = .systemBlue
        
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = TaskManager.shared.rememberTasks[indexPath.row]
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
