//
//  ReminderDateViewController.swift
//  MindSync
//

import UIKit

final class ReminderDateViewController: UIViewController {
    private let task: Task
    private let datePicker = UIDatePicker()
    
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Reminder"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let saveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBtn
        
        // Wrap date picker in a card
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.cornerCurve = .continuous
        
        cardView.addSubview(datePicker)
        view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            datePicker.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
    }
    
    @objc private func save() {
        TaskManager.shared.setReminderDate(datePicker.date, for: task.id)
        NotificationService.scheduleLongTermReminder(taskId: task.id, date: datePicker.date)
        navigationController?.popViewController(animated: true)
    }
}
