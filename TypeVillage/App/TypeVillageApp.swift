import SwiftUI
import ServiceManagement

@main
struct TypeVillageApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
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
        popover.contentSize = NSSize(width: 280, height: 420)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarContentView(appState: appState))
        popover.delegate = self

        // Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(openSettingsWindow), name: .openSettings, object: nil)

        // Level-up bubble hook — anchored to menu bar icon
        LevelUpToastManager.shared.anchorButton = statusItem.button
        appState.village.onLevelUp = { from, to, unlocked in
            LevelUpToastManager.shared.show(fromLevel: from, toLevel: to, unlocked: unlocked)
        }
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
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "TypeVillage Settings"
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
    }

    func popoverDidClose(_ notification: Notification) {
        // Clean up event monitor whenever popover closes (transient, manual, or via button)
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
    static let openSettings = Notification.Name("openSettings")
}

extension AppDelegate {
    /// If the app was launched from a DMG, ask to eject it
    private func ejectDMGIfNeeded() {
        let bundlePath = Bundle.main.bundlePath
        guard bundlePath.hasPrefix("/Volumes/") else { return }

        let components = bundlePath.split(separator: "/")
        guard components.count >= 2 else { return }
        let volumeName = String(components[1])
        let volumePath = "/Volumes/\(volumeName)"

        let fm = FileManager.default
        guard fm.fileExists(atPath: volumePath),
              volumeName.allSatisfy({ $0.isLetter || $0.isNumber || $0 == " " || $0 == "-" || $0 == "_" || $0 == "." })
        else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard fm.fileExists(atPath: volumePath) else { return }

            let alert = NSAlert()
            alert.messageText = "디스크 이미지를 마운트 해제할까요?"
            alert.informativeText = "TypeVillage를 Applications 폴더로 옮긴 후 디스크 이미지를 해제하는 것을 권장합니다."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "해제")
            alert.addButton(withTitle: "나중에")

            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.unmountAndEjectDevice(atPath: volumePath)
            }
        }
    }
}
