//
//  SpeechRecognizer.swift
//  effectMobileTestTask
//
//  Created by Роман on 11.04.2025.
//

import Foundation
import Speech
import Combine
import AVFoundation

final class SpeechRecognizer: ObservableObject {
    
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var audioEngine = AVAudioEngine()
    private var task: SFSpeechRecognitionTask?
    
    @Published var transcribedText: String = ""
    
    func startRecording() {
        print("START RECORDING")
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                return print("Запись не разрешена")
            }
            self.prepareAndStart()
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        request.endAudio()
        task?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func prepareAndStart() {
        
        guard !audioEngine.isRunning else {
            print("⚠️ AudioEngine уже запущен")
            return
        }
        
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        
        node.removeTap(onBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request.append(buffer)
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            audioEngine.prepare()
            try audioEngine.start()
            print("🎤 AudioEngine успешно запущен")
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            
            if let error = error {
                print("❌ Ошибка распознавания: \(error.localizedDescription)")
            }
        }
        } catch {
            print("💥 Не удалось запустить движок: \(error.localizedDescription)")
            return
        }
    }
}
