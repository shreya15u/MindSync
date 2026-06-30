//
//  Task.swift
//  MindSync
//

import Foundation

struct Task: Codable, Identifiable {
    let id: UUID
    var text: String
    var isUrgent: Bool
    var isImportant: Bool
    var isRemember: Bool
    var reminderDate: Date?
    var isCompleted: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        text: String,
        isUrgent: Bool = false,
        isImportant: Bool = false,
        isRemember: Bool = false,
        reminderDate: Date? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.isUrgent = isUrgent
        self.isImportant = isImportant
        self.isRemember = isRemember
        self.reminderDate = reminderDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
