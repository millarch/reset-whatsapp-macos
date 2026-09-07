import AppKit
import Foundation

private let appName = "Reset WhatsApp"
private let whatsAppBundleID = "net.whatsapp.WhatsApp"
private let whatsAppPath = "/Applications/WhatsApp.app"
private let appStoreURL = URL(string: "macappstore://itunes.apple.com/app/id310633997")!
private let fileManager = FileManager.default
private let homeURL = fileManager.homeDirectoryForCurrentUser

private func showAlert(title: String = appName, message: String, style: NSAlert.Style = .informational) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = style
    alert.addButton(withTitle: "OK")
    alert.runModal()
}

private func chooseReset() -> Bool? {
    let alert = NSAlert()
    alert.messageText = appName
    alert.informativeText = "Choose a reset type. Local WhatsApp data will be permanently deleted and no backups will be kept. Chats remain on your phone. You will then need to relink this Mac using the QR code."
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Standard Reset")
    alert.addButton(withTitle: "Full Reset")
    alert.addButton(withTitle: "Cancel")

    switch alert.runModal() {
    case .alertFirstButtonReturn:
        return false
    case .alertSecondButtonReturn:
        return true
    default:
        return nil
    }
}

private func confirmReset(fullReset: Bool) -> Bool {
    let alert = NSAlert()
    alert.messageText = fullReset ? "Confirm Full Reset?" : "Confirm Standard Reset?"
    alert.informativeText = fullReset
        ? "This permanently deletes local WhatsApp data and the application itself. Messages, media, or drafts that have not yet synchronized may be lost. This utility cannot recover the deleted information."
        : "This permanently deletes local WhatsApp data. Messages, media, or drafts that have not yet synchronized may be lost. This utility cannot recover the deleted information."
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Delete and Continue")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
}

private func runProcess(_ executable: String, _ arguments: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try? process.run()
    process.waitUntilExit()
}

private func stopWhatsApp() {
    for application in NSRunningApplication.runningApplications(withBundleIdentifier: whatsAppBundleID) {
        application.terminate()
    }
    Thread.sleep(forTimeInterval: 1.0)
    for application in NSRunningApplication.runningApplications(withBundleIdentifier: whatsAppBundleID) {
        application.forceTerminate()
    }
}

private func libraryPath(_ relativePath: String) -> String {
    homeURL.appendingPathComponent("Library", isDirectory: true)
        .appendingPathComponent(relativePath, isDirectory: true).path
}

private func deleteItem(at path: String) -> String? {
    let standardizedPath = URL(fileURLWithPath: path).standardizedFileURL.path
    let libraryPrefix = homeURL.appendingPathComponent("Library", isDirectory: true).path + "/"
    guard standardizedPath.hasPrefix(libraryPrefix) || standardizedPath == whatsAppPath else {
        return "\(path) — target rejected by the safety check"
    }
    guard fileManager.fileExists(atPath: standardizedPath) else {
        return nil
    }
    do {
        try fileManager.removeItem(atPath: standardizedPath)
        return nil
    } catch {
        return "\(path) — \(error.localizedDescription)"
    }
}

private func openWhatsAppOrStore() {
    if fileManager.fileExists(atPath: whatsAppPath) {
        NSWorkspace.shared.openApplication(
            at: URL(fileURLWithPath: whatsAppPath),
            configuration: NSWorkspace.OpenConfiguration()
        )
    } else {
        NSWorkspace.shared.open(appStoreURL)
    }
}

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
application.activate(ignoringOtherApps: true)

let arguments = CommandLine.arguments
if arguments.contains("--diagnose") {
    print(libraryPath("Containers/net.whatsapp.WhatsApp/Data"))
    exit(EXIT_SUCCESS)
}

let fullReset: Bool
if let selection = chooseReset() {
    fullReset = selection
} else {
    exit(EXIT_SUCCESS)
}

if !confirmReset(fullReset: fullReset) {
    exit(EXIT_SUCCESS)
}

stopWhatsApp()

var targets = [
    libraryPath("Containers/net.whatsapp.WhatsApp/Data"),
    libraryPath("Containers/net.whatsapp.WhatsApp.WAAppKitBridgeService/Data"),
    libraryPath("Containers/net.whatsapp.WhatsApp.ServiceExtension/Data"),
    libraryPath("Containers/net.whatsapp.WhatsApp.Intents/Data"),
    libraryPath("Group Containers/group.net.whatsapp.WhatsApp.shared"),
    libraryPath("Group Containers/group.net.whatsapp.WhatsApp.private"),
    libraryPath("Group Containers/group.net.whatsapp.family"),
    libraryPath("Group Containers/group.net.whatsapp.WhatsAppSMB.shared"),
    libraryPath("Group Containers/57T9237FN3.desktop.WhatsApp"),
    libraryPath("Containers/desktop.WhatsApp/Data"),
    libraryPath("Preferences/net.whatsapp.WhatsApp.plist"),
    libraryPath("Preferences/WhatsApp.plist"),
    libraryPath("Preferences/WhatsApp-Helper.plist"),
    libraryPath("Saved Application State/net.whatsapp.WhatsApp.savedState"),
    libraryPath("Saved Application State/desktop.WhatsApp.savedState"),
    libraryPath("HTTPStorages/net.whatsapp.WhatsApp"),
    libraryPath("HTTPStorages/WhatsApp"),
    libraryPath("Caches/net.whatsapp.WhatsApp"),
    libraryPath("Caches/WhatsApp"),
    libraryPath("Application Support/WhatsApp"),
    libraryPath("WebKit/net.whatsapp.WhatsApp")
]

if fullReset {
    targets.append(whatsAppPath)
}

let failures = targets.compactMap(deleteItem)
runProcess("/usr/bin/killall", ["cfprefsd"])

if !failures.isEmpty {
    let details = failures.joined(separator: "\n")
    showAlert(
        message: "The reset could not be completed:\n\n\(details)\n\nRemove the previous Reset WhatsApp entry in System Settings › Privacy & Security › Full Disk Access, add /Applications/Reset WhatsApp.app again, and try again.",
        style: .critical
    )
    exit(EXIT_FAILURE)
}

if fullReset {
    showAlert(message: "Full reset complete. Local data and the app were deleted. The Mac App Store will open so you can reinstall WhatsApp.")
    NSWorkspace.shared.open(appStoreURL)
} else {
    showAlert(message: "Reset complete. Local data was deleted. WhatsApp will open in a clean state; relink this Mac with the QR code.")
    openWhatsAppOrStore()
}
