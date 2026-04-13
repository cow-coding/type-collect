import Foundation
import Combine

final class SessionTracker: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var lastCheckedCount: Int = 0
    private var keystrokesSinceLastDrop: Int = 0
    private var hasEverDropped: Bool

    private let keystrokeMonitor: KeystrokeMonitor
    private let onDrop: (Keycap, Int) -> Void

    init(keystrokeMonitor: KeystrokeMonitor, initialKeystrokesSinceLastDrop: Int = 0, hasEverDropped: Bool = false, onDrop: @escaping (Keycap, Int) -> Void) {
        self.keystrokeMonitor = keystrokeMonitor
        self.keystrokesSinceLastDrop = initialKeystrokesSinceLastDrop
        self.hasEverDropped = hasEverDropped
        self.onDrop = onDrop

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
        while lastCheckedCount < currentCount {
            lastCheckedCount += 1
            keystrokesSinceLastDrop += 1
            let isFirstDrop = !hasEverDropped
            if let keycap = DropEngine.executeDrop(keystrokesSinceLastDrop: keystrokesSinceLastDrop, isFirstDrop: isFirstDrop) {
                keystrokesSinceLastDrop = 0
                hasEverDropped = true
                onDrop(keycap, lastCheckedCount)
            }
        }
    }

    var currentPityCount: Int {
        keystrokesSinceLastDrop
    }
}
