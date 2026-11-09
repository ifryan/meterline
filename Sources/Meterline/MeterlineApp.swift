// SPDX-License-Identifier: GPL-3.0-only
import AppKit

@main
struct MeterlineApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        if !AppEnvironment.isDemo, !LegacyMigration.runAtLaunch() { return }
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.mainMenu = makeMainMenu()
        app.run()
    }

    @MainActor
    private static func makeMainMenu() -> NSMenu {
        let menu = NSMenu()
        let applicationMenu = NSMenu()
        applicationMenu.addItem(withTitle: L("Quit Meterline"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(withTitle: "Meterline", action: nil, keyEquivalent: "").submenu = applicationMenu

        // SwiftUI sheets have their own windows; route editing shortcuts through the responder chain.
        let editMenu = NSMenu(title: L("Edit"))
        editMenu.addItem(withTitle: L("Undo"), action: Selector(("undo:")), keyEquivalent: "z")
        let redo = editMenu.addItem(withTitle: L("Redo"), action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: L("Cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: L("Copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: L("Paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: L("Select All"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        menu.addItem(withTitle: L("Edit"), action: nil, keyEquivalent: "").submenu = editMenu
        return menu
    }
}
