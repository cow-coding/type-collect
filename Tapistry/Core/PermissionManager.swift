import Foundation
import CoreGraphics
import AppKit

final class PermissionManager: ObservableObject {
    @Published var hasPermission: Bool = false

    init() {
        checkPermission()
    }

    func checkPermission() {
        // CGPreflightListenEventAccess is unreliable during development,
        // so we attempt to create an event tap to verify permission
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
        if let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .tailAppendEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { _, _, event, _ in Unmanaged.passUnretained(event) },
            userInfo: nil
        ) {
            // Tap created successfully → permission granted, clean up and release
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
            hasPermission = true
        } else {
            hasPermission = false
        }
    }

    func requestPermission() {
        _ = CGRequestListenEventAccess()
        checkPermission()

        if !hasPermission {
            openInputMonitoringSettings()
        }
    }

    func openInputMonitoringSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
            NSWorkspace.shared.open(url)
        }
    }
}
