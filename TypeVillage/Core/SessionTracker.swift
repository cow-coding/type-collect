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
        let delta = currentCount - lastCheckedCount
        guard delta > 0 else { return }

        // Cap per-evaluation loop to prevent UI freeze on large jumps
        let maxIterations = min(delta, 500)
        for _ in 0..<maxIterations {
            lastCheckedCount += 1
            keystrokesSinceLastDrop += 1
            let isFirstDrop = !hasEverDropped
            if let keycap = DropEngine.executeDrop(keystrokesSinceLastDrop: keystrokesSinceLastDrop, isFirstDrop: isFirstDrop) {
                keystrokesSinceLastDrop = 0
                hasEverDropped = true
                onDrop(keycap, lastCheckedCount)
            }
        }

        // Skip remaining keystrokes if delta was huge (app resume scenario)
        if delta > 500 {
            let skipped = delta - 500
            lastCheckedCount += skipped
            keystrokesSinceLastDrop += skipped

            // If pity threshold was crossed during skip, trigger guaranteed drop
            if keystrokesSinceLastDrop >= 2000 {
                if let keycap = DropEngine.executeDrop(keystrokesSinceLastDrop: 2000, isFirstDrop: false) {
                    keystrokesSinceLastDrop = 0
                    hasEverDropped = true
                    onDrop(keycap, lastCheckedCount)
                }
            }
        }
    }

    var currentPityCount: Int {
        keystrokesSinceLastDrop
    }
}
