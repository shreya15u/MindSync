//
//  SpeechService.swift
//  MindSync
//

import Foundation
import Speech
import AVFoundation
import Combine

final class SpeechService: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    var onTranscript: ((String) -> Void)?
    var onFinalTranscript: ((String) -> Void)?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                OperationQueue.main.addOperation { completion(false) }
                return
            }

            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                OperationQueue.main.addOperation { completion(granted) }
            }
        }
    }

    func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }

        recognitionTask?.cancel()
        recognitionTask = nil
        transcript = ""

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString
                OperationQueue.main.addOperation { [weak self] in
                    guard let self else { return }
                    self.transcript = text
                    self.onTranscript?(text)
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                let isFinal = result?.isFinal ?? false
                let finalText = result?.bestTranscription.formattedString ?? self.transcript

                OperationQueue.main.addOperation { [weak self] in
                    guard let self else { return }
                    self.transcript = finalText
                    self.isRecording = false
                    if isFinal {
                        self.onFinalTranscript?(finalText)
                    }
                }

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        isRecording = false
    }
}
