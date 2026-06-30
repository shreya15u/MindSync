//
//  TaskParser.swift
//  MindSync
//

import Foundation

enum TaskParser {
    static func parse(text: String) -> [Task] {
        let separators = CharacterSet(charactersIn: ".?!")
        let sentences = text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        return sentences.map { Task(text: $0) }
    }
}
