import Foundation
import Combine

@MainActor
class TimerService: ObservableObject {
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isRunning: Bool = false
    
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private var timerTask: Task<Void, Never>?
    
    func start() {
        guard !isRunning else { return }
        
        startTime = Date()
        isRunning = true
        
        timerTask = Task {
            for await _ in Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().values {
                guard !Task.isCancelled else { break }
                await updateElapsedTime()
            }
        }
    }
    
    func pause() {
        guard isRunning else { return }
        
        if let startTime = startTime {
            pausedTime += Date().timeIntervalSince(startTime)
        }
        
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    func resume() {
        guard !isRunning else { return }
        start()
    }
    
    func reset() {
        pause()
        elapsedTime = 0
        pausedTime = 0
        startTime = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = pausedTime + Date().timeIntervalSince(startTime)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}