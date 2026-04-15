import AppKit
import SwiftUI

final class WelcomeWindowController: NSObject, NSWindowDelegate {
    static let shared = WelcomeWindowController()

    private var window: NSWindow?

    func showIfNeeded() {
        guard !AppSettings.shared.hasCompletedOnboarding else { return }
        show()
    }

    private func show() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let welcomeView = WelcomeView {
            self.window?.close()
        }
        let hostingController = NSHostingController(rootView: welcomeView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 520),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.appearance = NSAppearance(named: .darkAqua)
        window.backgroundColor = NSColor(red: 0.047, green: 0.055, blue: 0.071, alpha: 1.0)
        window.contentViewController = hostingController
        window.setContentSize(NSSize(width: 480, height: 520))
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        // Back to accessory (menu bar only) mode
        NSApp.setActivationPolicy(.accessory)
    }
}
