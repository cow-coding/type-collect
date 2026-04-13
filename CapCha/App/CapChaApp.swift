import SwiftUI

@main
struct CapChaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var appState: AppState!

    func applicationDidFinishLaunching(_ notification: Notification) {
        ejectDMGIfNeeded()
        appState = AppState()

        // Create menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let icon = NSImage(named: "MenuBarIcon")
            icon?.isTemplate = true
            icon?.size = NSSize(width: 22, height: 22)
            button.image = icon
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Main popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarContentView(appState: appState))

        // Pass status item button to drop notification manager
        DropNotificationManager.shared.anchorButton = statusItem.button
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        appState.saveOnExit()
    }

    /// If the app was launched from a DMG, eject it
    private func ejectDMGIfNeeded() {
        let bundlePath = Bundle.main.bundlePath
        guard bundlePath.hasPrefix("/Volumes/") else { return }

        // Extract volume name (e.g. /Volumes/CapCha)
        let components = bundlePath.split(separator: "/")
        guard components.count >= 2 else { return }
        let volumePath = "/Volumes/\(components[1])"

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
            process.arguments = ["eject", volumePath]
            try? process.run()
        }
    }
}
