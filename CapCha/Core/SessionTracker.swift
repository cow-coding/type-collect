import Foundation
import Combine

final class SessionTracker: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var lastCheckedCount: Int = 0

    private let keystrokeMonitor: KeystrokeMonitor
    private let onDrop: (Keycap, Int) -> Void

    init(keystrokeMonitor: KeystrokeMonitor, onDrop: @escaping (Keycap, Int) -> Void) {
        self.keystrokeMonitor = keystrokeMonitor
        self.onDrop = onDrop

        // Start from current count to avoid re-evaluating persisted keystrokes
        lastCheckedCount = keystrokeMonitor.totalCount

        keystrokeMonitor.$totalCount
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.evaluate(currentCount: count)
            }
            .store(in: &cancellables)
    }

    private func evaluate(currentCount: Int) {
        // Evaluate drop for each keystroke
        while lastCheckedCount < currentCount {
            lastCheckedCount += 1
            if let keycap = DropEngine.executeDrop() {
                onDrop(keycap, lastCheckedCount)
            }
        }
    }
}
