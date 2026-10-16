import AppKit

final class MainWindowController: NSWindowController, NSToolbarDelegate {
    private static let titleItemIdentifier = NSToolbarItem.Identifier("BackdateTitle")

    convenience init() {
        let contentViewController = MainViewController()
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: Layout.Window.contentSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        self.init(window: window)
        window.contentViewController = contentViewController
        configure(window)
    }

    private func configure(_ window: NSWindow) {
        window.title = "Backdate"
        window.titleVisibility = .hidden
        window.toolbarStyle = .unified
        window.titlebarSeparatorStyle = .line
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true
        window.collectionBehavior.insert(.fullScreenNone)

        let toolbar = NSToolbar(identifier: "BackdateToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        toolbar.centeredItemIdentifiers = [Self.titleItemIdentifier]
        window.toolbar = toolbar

        window.standardWindowButton(.zoomButton)?.isEnabled = false
        var frame = window.frame
        frame.size = Layout.Window.frameSize
        window.setFrame(frame, display: false)
        window.center()
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [Self.titleItemIdentifier]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [Self.titleItemIdentifier]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        guard itemIdentifier == Self.titleItemIdentifier else { return nil }

        let title = NSTextField(labelWithString: "Backdate")
        title.font = .systemFont(ofSize: Layout.Window.titlePointSize, weight: .bold)
        title.textColor = .labelColor
        title.alignment = .center
        title.setContentHuggingPriority(.required, for: .horizontal)

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = "Backdate"
        item.paletteLabel = "Backdate"
        item.view = title
        item.isNavigational = false
        return item
    }
}
