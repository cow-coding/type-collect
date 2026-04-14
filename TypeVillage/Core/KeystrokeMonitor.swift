import Foundation
import CoreGraphics
import Combine

final class KeystrokeMonitor: ObservableObject {
    @Published var totalCount: Int = 0
    private(set) var isRunning: Bool = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var retainedSelf: Unmanaged<KeystrokeMonitor>?

    deinit {
        stop()
    }

    func start() {
        guard eventTap == nil else { return }

        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon else { return Unmanaged.passUnretained(event) }

            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                let monitor = Unmanaged<KeystrokeMonitor>.fromOpaque(refcon).takeUnretainedValue()
                if let tap = monitor.eventTap {
                    CGEvent.tapEnable(tap: tap, enable: true)
                }
                return Unmanaged.passUnretained(event)
            }

            // SAFETY: This callback runs on the main run loop (see CFRunLoopGetMain() below).
            // totalCount is @Published and must only be mutated from the main thread.
            // Do NOT move the event tap source to a background run loop.
            let monitor = Unmanaged<KeystrokeMonitor>.fromOpaque(refcon).takeUnretainedValue()
            monitor.totalCount += 1
            return Unmanaged.passUnretained(event)
        }

        let retained = Unmanaged.passRetained(self)
        retainedSelf = retained
        let selfPtr = retained.toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .tailAppendEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: selfPtr
        ) else {
            #if DEBUG
            print("[KeystrokeMonitor] Failed to create event tap.")
            #endif
            retainedSelf?.release()
            retainedSelf = nil
            isRunning = false
            return
        }

        eventTap = tap
        isRunning = true

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        #if DEBUG
        print("[KeystrokeMonitor] Event tap started successfully.")
        #endif
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            runLoopSource = nil
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
        }
        retainedSelf?.release()
        retainedSelf = nil
        isRunning = false
    }

    func reEnableIfNeeded() {
        guard let tap = eventTap else { return }
        if !CGEvent.tapIsEnabled(tap: tap) {
            CGEvent.tapEnable(tap: tap, enable: true)
            #if DEBUG
            print("[KeystrokeMonitor] Re-enabled event tap.")
            #endif
        }
    }
}
