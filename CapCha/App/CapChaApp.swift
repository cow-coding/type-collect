import SwiftUI
import ServiceManagement

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
    private var eventMonitor: Any?

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

        // Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(openCollectionWindow), name: .openCollectionWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openSettingsWindow), name: .openSettings, object: nil)
    }

    @objc private func openCollectionWindow() {
        popover.performClose(nil)
        CollectionWindowController.shared.showWindow(appState: appState)
    }

    private var settingsWindow: NSWindow?

    @objc private func openSettingsWindow() {
        popover.performClose(nil)

        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "CapCha Settings"
        window.contentViewController = NSHostingController(rootView: SettingsView())
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            startEventMonitor()
        }
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        appState.saveOnExit()
    }

}

extension Notification.Name {
    static let openCollectionWindow = Notification.Name("openCollectionWindow")
    static let openSettings = Notification.Name("openSettings")
}

extension AppDelegate {
    /// If the app was launched from a DMG, eject it
    private func ejectDMGIfNeeded() {
        let bundlePath = Bundle.main.bundlePath
        guard bundlePath.hasPrefix("/Volumes/") else { return }

        let components = bundlePath.split(separator: "/")
        guard components.count >= 2 else { return }
        let volumeName = String(components[1])
        let volumePath = "/Volumes/\(volumeName)"

        // Validate: path must exist, must be a mount point, and name must be safe
        let fm = FileManager.default
        guard fm.fileExists(atPath: volumePath),
              volumeName.allSatisfy({ $0.isLetter || $0.isNumber || $0 == " " || $0 == "-" || $0 == "_" || $0 == "." })
        else { return }

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) {
            // Re-check the volume still exists right before ejecting
            guard fm.fileExists(atPath: volumePath) else { return }
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
            process.arguments = ["eject", volumePath]
            try? process.run()
        }
    }
}
