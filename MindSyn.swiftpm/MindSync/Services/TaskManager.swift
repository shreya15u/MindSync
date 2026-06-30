//
//  TaskManager.swift
//  MindSync
//

import Foundation
import Combine

final class TaskManager: ObservableObject {
    nonisolated(unsafe) static let shared = TaskManager()
    var taskDidUpdate: (() -> Void)?

    @Published private(set) var tasks: [Task] = []
    private let savedTasksKey = "saved_remember_tasks"

    private init() {
        loadSavedTasks()
    }

    // MARK: - Mutations

    func addTasks(_ newTasks: [Task]) {
        let valid = newTasks.filter { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !valid.isEmpty else { return }
        tasks.insert(contentsOf: valid, at: 0)
        notifyUpdate()
    }

    func updateTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        if task.isRemember { persistSavedTasks() }
        notifyUpdate()
    }

    func removeTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        persistSavedTasks()
        notifyUpdate()
    }

    func toggleUrgent(for taskId: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[i].isUrgent.toggle()
        notifyUpdate()
    }

    func toggleImportant(for taskId: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[i].isImportant.toggle()
        notifyUpdate()
    }

    func toggleRemember(for taskId: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[i].isRemember.toggle()
        persistSavedTasks()
        notifyUpdate()
    }

    func toggleCompleted(for taskId: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[i].isCompleted.toggle()
        persistSavedTasks()
        notifyUpdate()
    }

    func setReminderDate(_ date: Date?, for taskId: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[i].reminderDate = date
        persistSavedTasks()
        notifyUpdate()
    }

    func task(by id: UUID) -> Task? {
        tasks.first { $0.id == id }
    }

    // MARK: - Computed

    var urgentTasks: [Task] { tasks.filter { $0.isUrgent && !$0.isCompleted } }
    var rememberTasks: [Task] { tasks.filter { $0.isRemember } }
    var activeTasks: [Task] { tasks.filter { !$0.isCompleted } }

    // MARK: - Persistence

    private func persistSavedTasks() {
        let data = try? JSONEncoder().encode(tasks.filter { $0.isRemember })
        UserDefaults.standard.set(data, forKey: savedTasksKey)
    }

    private func loadSavedTasks() {
        guard
            let data = UserDefaults.standard.data(forKey: savedTasksKey),
            let decoded = try? JSONDecoder().decode([Task].self, from: data)
        else { return }
        tasks = decoded
        notifyUpdate()
    }

    private func notifyUpdate() {
        taskDidUpdate?()
    }
}
