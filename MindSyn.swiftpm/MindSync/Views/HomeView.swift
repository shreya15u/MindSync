//
//  HomeView.swift
//  MindSync
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var taskManager: TaskManager
    @StateObject private var speech = SpeechService()

    @State private var permissionGranted = false
    @State private var showPermissionAlert = false
    @State private var showAddedAlert = false
    @State private var addedCount = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var isTypingMode = false
    @State private var typedText = ""
    @FocusState private var isTypingFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Subtitle
                    Text("Speak naturally to create tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Stats bar
                    if !taskManager.tasks.isEmpty {
                        statsView
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Transcript card
                    transcriptCard

                    // Mic button
                    HStack {
                        micButton
                        typingButton
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                    // Status
                    let statusText = isTypingMode ? "Typing…" : (speech.isRecording ? "Listening…" : "")
                    if !statusText.isEmpty {
                        HStack {
                            Spacer()
                            Text(statusText)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }

                    tasksSection
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut, value: taskManager.tasks.count)
        }
        .onAppear { requestPermissions() }
        .alert("Permissions Required", isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enable Microphone and Speech Recognition in Settings to use voice capture.")
        }
        .alert("Tasks Created", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(addedCount) task(s) added. You can manage tags right below.")
        }
    }

    // MARK: - Sub-views

    private var statsView: some View {
        let total = taskManager.tasks.count
        let completed = taskManager.tasks.filter { $0.isCompleted }.count
        let urgent = taskManager.urgentTasks.count
        var parts: [String] = ["\(total) task\(total == 1 ? "" : "s")"]
        if completed > 0 { parts.append("✓ \(completed) done") }
        if urgent > 0 { parts.append("⚡ \(urgent) urgent") }
        return Text(parts.joined(separator: "  ·  "))
            .font(.footnote)
            .foregroundStyle(.indigo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.indigo.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var transcriptCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(uiColor: .separator), lineWidth: 0.5)
                )
                .frame(height: 200)

            if isTypingMode {
                TextEditor(text: $typedText)
                    .focused($isTypingFocused)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(height: 200)

                if typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Type your tasks here…")
                        .foregroundStyle(Color(uiColor: .placeholderText))
                        .font(.body)
                        .padding(18)
                        .allowsHitTesting(false)
                }
            } else {
                if speech.transcript.isEmpty {
                    Text("Add the task")
                        .foregroundStyle(Color(uiColor: .placeholderText))
                        .font(.body)
                        .padding(18)
                }

                ScrollView {
                    Text(speech.transcript)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                }
                .frame(height: 200)
            }
        }
    }

    private var micButton: some View {
        Button(action: toggleRecording) {
            Image(systemName: speech.isRecording ? "stop.fill" : "mic.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(speech.isRecording ? Color.red : Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                .scaleEffect(pulseScale)
        }
        .disabled(isTypingMode)
        .opacity(isTypingMode ? 0.45 : 1)
        .animation(.easeInOut, value: speech.isRecording)
        .onChange(of: speech.isRecording) { recording in
            if recording {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    pulseScale = 1.08
                }
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    pulseScale = 1.0
                }
            }
        }
    }

    private var typingButton: some View {
        Button(action: toggleTyping) {
            Image(systemName: isTypingMode ? "checkmark.circle.fill" : "keyboard.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(isTypingMode ? Color.green : Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Tasks")
                    .font(.headline)
                Spacer()
                if !taskManager.tasks.isEmpty {
                    Text("\(taskManager.tasks.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if taskManager.tasks.isEmpty {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        Text("No tasks yet. Record above to create your first task.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    )
                    .frame(height: 86)
            } else {
                let visibleRows = min(taskManager.tasks.count, 4)
                List {
                    ForEach(taskManager.tasks) { task in
                        taskCard(task)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    taskManager.removeTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(height: CGFloat(visibleRows) * 132)
            }
        }
        .padding(.bottom, 18)
    }

    private func taskCard(_ task: Task) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Text(task.text)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            HStack(spacing: 8) {
                tagButton(
                    title: "Urgent",
                    systemImage: "bolt.fill",
                    isOn: task.isUrgent,
                    tint: .red
                ) {
                    taskManager.toggleUrgent(for: task.id)
                }

                tagButton(
                    title: "Important",
                    systemImage: "exclamationmark.circle.fill",
                    isOn: task.isImportant,
                    tint: .orange
                ) {
                    taskManager.toggleImportant(for: task.id)
                }

                tagButton(
                    title: "Remember",
                    systemImage: "bookmark.fill",
                    isOn: task.isRemember,
                    tint: .blue
                ) {
                    taskManager.toggleRemember(for: task.id)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(uiColor: .separator), lineWidth: 0.4)
        )
    }

    private func tagButton(
        title: String,
        systemImage: String,
        isOn: Bool,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .background(isOn ? tint : tint.opacity(0.14))
        .foregroundStyle(isOn ? Color.white : tint)
        .clipShape(Capsule())
    }

    // MARK: - Actions

    private func toggleRecording() {
        guard !isTypingMode else { return }
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        if speech.isRecording {
            stopAndParse()
        } else {
            speech.startRecording()
        }
    }

    private func stopAndParse() {
        speech.stopRecording()
        processInputText(speech.transcript)
    }

    private func toggleTyping() {
        if isTypingMode {
            isTypingFocused = false
            isTypingMode = false
            processInputText(typedText)
            typedText = ""
        } else {
            if speech.isRecording {
                speech.stopRecording()
            }
            isTypingMode = true
            typedText = ""
            DispatchQueue.main.async {
                isTypingFocused = true
            }
        }
    }

    private func processInputText(_ rawText: String) {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let parsed = TaskParser.parse(text: text)
        guard !parsed.isEmpty else { return }
        taskManager.addTasks(parsed)
        addedCount = parsed.count
        showAddedAlert = true
    }

    private func requestPermissions() {
        speech.requestPermissions { granted in
            permissionGranted = granted
            if !granted { showPermissionAlert = true }
        }
    }
}
