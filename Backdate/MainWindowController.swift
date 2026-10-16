import AppKit

final class MainWindowController: NSWindowController, NSToolbarDelegate {
    private static let titleItemIdentifier = NSToolbarItem.Identifier("BackdateTitle")

    convenience init() {
        let contentViewController = MainViewController()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: Layout.Window.contentWidth, height: 1),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        self.init(window: window)
        window.contentViewController = contentViewController
        configure(window)
        sizeWindowToContent(window)
        window.center()
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
        toolbar.centeredItemIdentifier = Self.titleItemIdentifier
        window.toolbar = toolbar

        window.standardWindowButton(.zoomButton)?.isEnabled = false
    }

    private func sizeWindowToContent(_ window: NSWindow) {
        guard let contentView = window.contentView else { return }
        contentView.layoutSubtreeIfNeeded()
        window.setContentSize(
            NSSize(width: Layout.Window.contentWidth, height: contentView.fittingSize.height)
        )
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
        title.font = .preferredFont(forTextStyle: .headline)
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
