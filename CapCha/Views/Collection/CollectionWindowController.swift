import AppKit
import SwiftUI

final class CollectionWindowController: NSObject, NSWindowDelegate {
    static let shared = CollectionWindowController()

    private var window: NSWindow?

    func showWindow(appState: AppState) {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = CollectionView(appState: appState)
        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1080, height: 680),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "CapCha Collection"
        window.contentViewController = hostingController
        window.setContentSize(NSSize(width: 1080, height: 680))
        window.minSize = NSSize(width: 560, height: 400)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Show in Dock and Cmd+Tab while collection window is open
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        // Hide from Dock and Cmd+Tab when no windows are open
        NSApp.setActivationPolicy(.accessory)
    }
}
