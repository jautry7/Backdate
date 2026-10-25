import AppKit

final class MainViewController: NSViewController {
    private let fileArea = DropAreaView()
    private let datePicker = InsetDatePickerView()
    private let statusLabel = NSTextField(labelWithString: "")
    private let updateButton = NSButton(title: "Update", target: nil, action: nil)
    private var changeButtons: [NSButton] = []
    private var affectButtons: [NSButton] = []
    private var selectedFileURL: URL?
    private var isUpdating = false
    private var statusFadeWorkItem: DispatchWorkItem?

    override func loadView() {
        let rootView = NSView()
        view = rootView

        fileArea.translatesAutoresizingMaskIntoConstraints = false
        let fileSection = makeSection(title: "File", content: fileArea)
        fileSection.box.contentViewMargins = .zero
        fileArea.sourceBox = fileSection.box
        fileArea.onFileURLChanged = { [weak self] url in
            self?.selectedFileURL = url
            self?.clearStatus()
            self?.updateUpdateButtonState()
        }

        let dateDescription = NSTextField(labelWithString: "Format MM/DD/YYYY:")
        dateDescription.translatesAutoresizingMaskIntoConstraints = false
        let dateSpacer = NSView()
        dateSpacer.translatesAutoresizingMaskIntoConstraints = false
        let dateRow = NSStackView(views: [dateDescription, datePicker, dateSpacer])
        dateRow.orientation = .horizontal
        dateRow.alignment = .centerY
        dateRow.distribution = .fill
        dateRow.translatesAutoresizingMaskIntoConstraints = false
        let dateSection = makeSection(title: "New date", content: dateRow)

        let createdAndModifiedButton = makeRadioButton(
            title: "Both modified and created",
            action: #selector(changeSelectionChanged(_:))
        )
        let modifiedOnlyButton = makeRadioButton(
            title: "Modified date only",
            action: #selector(changeSelectionChanged(_:))
        )
        let createdOnlyButton = makeRadioButton(
            title: "Created date only",
            action: #selector(changeSelectionChanged(_:))
        )
        changeButtons = [createdAndModifiedButton, createdOnlyButton, modifiedOnlyButton]
        createdAndModifiedButton.state = .on
        let changeGroup = makeRadioGroup(changeButtons)
        let changeSection = makeSection(title: "Change", content: changeGroup)

        let justThisItemButton = makeRadioButton(
            title: "Just this item",
            action: #selector(affectSelectionChanged(_:))
        )
        let nextLevelButton = makeRadioButton(
            title: "This item and all next-level children",
            action: #selector(affectSelectionChanged(_:))
        )
        let everyNestedItemButton = makeRadioButton(
            title: "This item and every nested item",
            action: #selector(affectSelectionChanged(_:))
        )
        affectButtons = [justThisItemButton, nextLevelButton, everyNestedItemButton]
        justThisItemButton.state = .on
        let affectGroup = makeRadioGroup(affectButtons)
        let affectSection = makeSection(title: "Affect", content: affectGroup)

        statusLabel.textColor = .systemGreen
        statusLabel.lineBreakMode = .byTruncatingTail
        statusLabel.isHidden = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        updateButton.controlSize = .regular
        updateButton.keyEquivalent = "\r"
        updateButton.target = self
        updateButton.action = #selector(updateDates)
        updateButton.isEnabled = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false

        [
            fileSection,
            dateSection,
            changeSection,
            affectSection,
            statusLabel,
            updateButton,
        ].forEach(rootView.addSubview)

        NSLayoutConstraint.activate([
            fileSection.titleLabel.topAnchor.constraint(
                equalTo: rootView.topAnchor,
                constant: Layout.Content.topPadding
            ),
            fileSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            fileSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),
            fileArea.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Content.File.dropAreaHeight),

            dateSection.titleLabel.topAnchor.constraint(
                equalTo: fileSection.bottomAnchor,
                constant: Layout.Content.sectionSpacing
            ),
            dateSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            dateSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),

            changeSection.titleLabel.topAnchor.constraint(
                equalTo: dateSection.bottomAnchor,
                constant: Layout.Content.sectionSpacing
            ),
            changeSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            changeSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),

            affectSection.titleLabel.topAnchor.constraint(
                equalTo: changeSection.bottomAnchor,
                constant: Layout.Content.sectionSpacing
            ),
            affectSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            affectSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),

            updateButton.topAnchor.constraint(
                equalTo: affectSection.bottomAnchor,
                constant: Layout.Content.boxBottomMarginLast
            ),
            statusLabel.leadingAnchor.constraint(
                equalTo: rootView.leadingAnchor,
                constant: Layout.Content.horizontalPadding + Layout.Content.statusLeadingPadding
            ),
            statusLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: updateButton.leadingAnchor,
                constant: -Layout.Content.horizontalPadding
            ),
            statusLabel.centerYAnchor.constraint(equalTo: updateButton.centerYAnchor),
            updateButton.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),
            updateButton.bottomAnchor.constraint(
                equalTo: rootView.bottomAnchor,
                constant: -Layout.Content.bottomPadding
            ),
        ])
    }

    private func makeSection(title: String, content: NSView) -> SectionView {
        SectionView(title: title, content: content)
    }

    private func makeRadioButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(radioButtonWithTitle: title, target: self, action: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func makeRadioGroup(_ buttons: [NSButton]) -> NSStackView {
        let stack = NSStackView(views: buttons)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.distribution = .gravityAreas
        stack.spacing = Layout.RadioGroup.rowSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    @objc private func changeSelectionChanged(_ sender: NSButton) {
        select(sender, in: changeButtons)
    }

    @objc private func affectSelectionChanged(_ sender: NSButton) {
        select(sender, in: affectButtons)
    }

    private func select(_ selectedButton: NSButton, in group: [NSButton]) {
        for button in group {
            button.state = button === selectedButton ? .on : .off
        }
    }

    private func updateUpdateButtonState() {
        updateButton.isEnabled = selectedFileURL != nil && !isUpdating
    }

    @objc private func updateDates() {
        guard let selectedFileURL else { return }

        let changeMode: DateChangeMode
        switch changeButtons.firstIndex(where: { $0.state == .on }) {
        case 1:
            changeMode = .createdOnly
        case 2:
            changeMode = .modifiedOnly
        default:
            changeMode = .createdAndModified
        }
        let scope: ItemScope
        switch affectButtons.firstIndex(where: { $0.state == .on }) {
        case 1:
            scope = .nextLevel
        case 2:
            scope = .allDescendants
        default:
            scope = .selectedItem
        }

        isUpdating = true
        clearStatus()
        updateButton.title = "Updating…"
        updateUpdateButtonState()

        let date = datePicker.dateValue
        Task {
            let result = await Task.detached(priority: .userInitiated) {
                DateUpdater.update(
                    url: selectedFileURL,
                    date: date,
                    mode: changeMode,
                    scope: scope
                )
            }.value
            finishUpdate(result, changeMode: changeMode)
        }
    }

    private func finishUpdate(_ result: DateUpdateResult, changeMode: DateChangeMode) {
        isUpdating = false
        updateButton.title = "Update"
        updateUpdateButtonState()

        if result.failures.isEmpty {
            switch changeMode {
            case .createdOnly:
                showStatus("Changed date created")
            case .modifiedOnly:
                showStatus("Changed date modified")
            case .createdAndModified:
                showStatus("Changed date modified & date created")
            }
            return
        }

        let alert = NSAlert()
        alert.alertStyle = result.updatedCount == 0 ? .critical : .warning
        alert.messageText = result.updatedCount == 0
            ? "The dates could not be updated"
            : "Some items could not be updated"

        let failureSummary = result.failures.prefix(3).map {
            "\($0.url.lastPathComponent): \($0.message)"
        }.joined(separator: "\n")
        let remainingCount = result.failures.count - min(3, result.failures.count)
        alert.informativeText = failureSummary
            + (remainingCount > 0 ? "\n…and \(remainingCount) more." : "")

        if let window = view.window {
            alert.beginSheetModal(for: window)
        } else {
            alert.runModal()
        }
    }

    private func clearStatus() {
        statusFadeWorkItem?.cancel()
        statusFadeWorkItem = nil
        statusLabel.stringValue = ""
        statusLabel.alphaValue = 1
        statusLabel.isHidden = true
    }

    private func showStatus(_ message: String) {
        clearStatus()
        statusLabel.stringValue = message
        statusLabel.isHidden = false

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                self.statusLabel.animator().alphaValue = 0
            } completionHandler: {
                self.clearStatus()
            }
        }
        statusFadeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}

private final class SectionView: NSView {
    let box = SectionBox()
    let titleLabel: NSTextField

    init(title: String, content: NSView) {
        titleLabel = NSTextField(labelWithString: title)
        super.init(frame: .zero)

        let titleFont = NSFont.preferredFont(forTextStyle: .callout)
        titleLabel.font = .systemFont(ofSize: titleFont.pointSize, weight: .semibold)
        titleLabel.textColor = .secondaryLabelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        box.titlePosition = .noTitle
        box.contentViewMargins = NSSize(
            width: Layout.Section.ContentPadding.horizontal,
            height: Layout.Section.ContentPadding.vertical
        )
        box.translatesAutoresizingMaskIntoConstraints = false

        addSubview(box)
        addSubview(titleLabel)

        guard let contentView = box.contentView else { return }
        contentView.addSubview(content)

        NSLayoutConstraint.activate([
            box.leadingAnchor.constraint(equalTo: leadingAnchor),
            box.trailingAnchor.constraint(equalTo: trailingAnchor),
            box.topAnchor.constraint(equalTo: topAnchor),
            box.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(
                equalTo: box.topAnchor,
                constant: -Layout.Section.titleToBoxSpacing
            ),

            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            content.topAnchor.constraint(equalTo: contentView.topAnchor),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        nil
    }
}

private final class SectionBox: NSBox {

    override var intrinsicContentSize: NSSize {
        let nativeSize = super.intrinsicContentSize
        let contentHeight = contentView?.fittingSize.height ?? 0

        return NSSize(
            width: nativeSize.width,
            height: contentHeight + (contentViewMargins.height * 2)
        )
    }
}

private final class DropAreaView: NSView {
    var onFileURLChanged: ((URL?) -> Void)?

    weak var sourceBox: NSBox? {
        didSet { needsLayout = true }
    }

    private let promptLabel = NSTextField(labelWithString: "Drop your file here")
    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let pathLabel = NSTextField(labelWithString: "")
    private let removeButton = NSButton()
    private let previewView = NSView()
    private let borderLayer = CAShapeLayer()
    private var fileURL: URL? {
        didSet {
            updateFilePreview()
            onFileURLChanged?(fileURL)
        }
    }
    private var isDragHighlighted = false {
        didSet { needsDisplay = true }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.masksToBounds = true

        borderLayer.fillColor = nil
        borderLayer.lineWidth = Layout.Content.File.borderWidth
        borderLayer.lineCap = .round
        borderLayer.lineDashPattern = [
            NSNumber(value: Layout.Content.File.dashLength),
            NSNumber(value: Layout.Content.File.dashSpacing),
        ]
        layer?.addSublayer(borderLayer)

        promptLabel.font = NSFont.preferredFont(forTextStyle: .title3)
        promptLabel.alignment = .center
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(promptLabel)

        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleFont = NSFont.preferredFont(forTextStyle: .title3)
        titleLabel.font = .systemFont(ofSize: titleFont.pointSize, weight: .semibold)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        pathLabel.font = NSFont.preferredFont(forTextStyle: .callout)
        pathLabel.textColor = .secondaryLabelColor
        pathLabel.lineBreakMode = .byTruncatingTail
        pathLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        pathLabel.translatesAutoresizingMaskIntoConstraints = false

        let textStack = NSStackView(views: [titleLabel, pathLabel])
        textStack.orientation = .vertical
        textStack.alignment = .leading
        textStack.spacing = Layout.Content.File.Preview.textLineSpacing
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textStack.translatesAutoresizingMaskIntoConstraints = false

        removeButton.image = NSImage(
            systemSymbolName: "xmark.circle",
            accessibilityDescription: "Remove file"
        )?.withSymbolConfiguration(
            .init(pointSize: Layout.Content.File.Preview.closeButtonSize, weight: .regular)
        )
        removeButton.imagePosition = .imageOnly
        removeButton.isBordered = false
        removeButton.contentTintColor = .tertiaryLabelColor
        removeButton.toolTip = "Remove file"
        removeButton.target = self
        removeButton.action = #selector(removeFile)
        removeButton.translatesAutoresizingMaskIntoConstraints = false

        previewView.addSubview(iconView)
        previewView.addSubview(textStack)
        previewView.addSubview(removeButton)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.isHidden = true
        addSubview(previewView)

        NSLayoutConstraint.activate([
            promptLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            promptLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewView.topAnchor.constraint(equalTo: topAnchor),
            previewView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.leadingAnchor.constraint(
                equalTo: previewView.leadingAnchor,
                constant: Layout.Content.File.Preview.leadingPadding
            ),
            iconView.centerYAnchor.constraint(equalTo: previewView.centerYAnchor),
            iconView.topAnchor.constraint(
                greaterThanOrEqualTo: previewView.topAnchor,
                constant: Layout.Content.File.Preview.verticalPadding
            ),
            iconView.bottomAnchor.constraint(
                lessThanOrEqualTo: previewView.bottomAnchor,
                constant: -Layout.Content.File.Preview.verticalPadding
            ),
            iconView.widthAnchor.constraint(equalToConstant: Layout.Content.File.Preview.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Layout.Content.File.Preview.iconSize),

            textStack.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor,
                constant: Layout.Content.File.Preview.iconTextSpacing
            ),
            textStack.centerYAnchor.constraint(equalTo: previewView.centerYAnchor),
            textStack.topAnchor.constraint(
                greaterThanOrEqualTo: previewView.topAnchor,
                constant: Layout.Content.File.Preview.verticalPadding
            ),
            textStack.bottomAnchor.constraint(
                lessThanOrEqualTo: previewView.bottomAnchor,
                constant: -Layout.Content.File.Preview.verticalPadding
            ),

            removeButton.leadingAnchor.constraint(
                equalTo: textStack.trailingAnchor,
                constant: Layout.Content.File.Preview.textCloseButtonSpacing
            ),
            removeButton.trailingAnchor.constraint(
                equalTo: previewView.trailingAnchor,
                constant: -Layout.Content.File.Preview.trailingPadding
            ),
            removeButton.centerYAnchor.constraint(equalTo: previewView.centerYAnchor),
            removeButton.widthAnchor.constraint(
                equalToConstant: Layout.Content.File.Preview.closeButtonSize
            ),
            removeButton.heightAnchor.constraint(
                equalToConstant: Layout.Content.File.Preview.closeButtonSize
            ),
        ])

        registerForDraggedTypes([.fileURL])
        needsDisplay = true
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()
        let cornerRadius = sourceBox?.systemBackgroundCornerRadius ?? 0
        layer?.cornerRadius = cornerRadius
        let borderInset = Layout.Content.File.borderWidth / 2
        borderLayer.path = CGPath(
            roundedRect: bounds.insetBy(dx: borderInset, dy: borderInset),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
    }

    override var wantsUpdateLayer: Bool {
        true
    }

    override func updateLayer() {
        effectiveAppearance.performAsCurrentDrawingAppearance {
            borderLayer.strokeColor = isDragHighlighted
                ? NSColor.controlAccentColor.cgColor
                : NSColor.separatorColor.cgColor
            layer?.backgroundColor = if isDragHighlighted {
                NSColor.controlAccentColor.withAlphaComponent(0.08).cgColor
            } else if fileURL != nil {
                NSColor.controlBackgroundColor.cgColor
            } else {
                NSColor.clear.cgColor
            }
        }
        borderLayer.lineDashPattern = fileURL == nil
            ? [
                NSNumber(value: Layout.Content.File.dashLength),
                NSNumber(value: Layout.Content.File.dashSpacing),
            ]
            : nil
        promptLabel.textColor = isDragHighlighted ? .controlAccentColor : .secondaryLabelColor
        promptLabel.alphaValue = isDragHighlighted ? 1 : 0.7
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        needsDisplay = true
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        updateDragState(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        updateDragState(sender)
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragHighlighted = false
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDragHighlighted = false
        guard let url = draggedFileURLs(from: sender).first else {
            return false
        }

        fileURL = url
        return true
    }

    private func updateDragState(_ sender: NSDraggingInfo) -> NSDragOperation {
        let fileURLs = draggedFileURLs(from: sender)
        let acceptsDrop = fileURLs.count == 1
            && FileManager.default.fileExists(atPath: fileURLs[0].path)
        isDragHighlighted = acceptsDrop
        return acceptsDrop ? .copy : []
    }

    private func draggedFileURLs(from sender: NSDraggingInfo) -> [URL] {
        sender.draggingPasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        ) as? [URL] ?? []
    }

    private func updateFilePreview() {
        guard let fileURL else {
            promptLabel.isHidden = false
            previewView.isHidden = true
            needsDisplay = true
            return
        }

        let friendlyPath = (fileURL.path as NSString).abbreviatingWithTildeInPath
        iconView.image = NSWorkspace.shared.icon(forFile: fileURL.path)
        titleLabel.stringValue = fileURL.lastPathComponent
        pathLabel.stringValue = friendlyPath
        pathLabel.toolTip = fileURL.path
        promptLabel.isHidden = true
        previewView.isHidden = false
        needsDisplay = true
    }

    @objc private func removeFile() {
        fileURL = nil
    }

}

private extension NSBox {
    var systemBackgroundCornerRadius: CGFloat? {
        layoutSubtreeIfNeeded()

        return subviews
            .filter { $0 !== contentView }
            .compactMap(\.layer)
            .flatMap(positiveCornerRadii(in:))
            .max()
    }

    func positiveCornerRadii(in rootLayer: CALayer) -> [CGFloat] {
        let ownRadius = rootLayer.cornerRadius > 0 ? [rootLayer.cornerRadius] : []
        return ownRadius + (rootLayer.sublayers ?? []).flatMap(positiveCornerRadii(in:))
    }
}

private final class InsetDatePickerView: NSView {
    private let datePicker: NSDatePicker

    var dateValue: Date {
        datePicker.dateValue
    }

    override init(frame frameRect: NSRect) {
        datePicker = NSDatePicker()
        super.init(frame: frameRect)

        datePicker.datePickerStyle = .textField
        datePicker.datePickerElements = [.yearMonthDay, .hourMinute]
        datePicker.dateValue = Date()
        datePicker.controlSize = .regular
        datePicker.isBezeled = false
        datePicker.isBordered = false
        datePicker.drawsBackground = false
        datePicker.presentsCalendarOverlay = false
        datePicker.setContentHuggingPriority(.required, for: .horizontal)
        datePicker.setContentHuggingPriority(.required, for: .vertical)
        datePicker.setContentCompressionResistancePriority(.required, for: .horizontal)
        datePicker.setContentCompressionResistancePriority(.required, for: .vertical)
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Layout.DatePicker.ContentPadding.leading
            ),
            datePicker.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Layout.DatePicker.ContentPadding.trailing
            ),
            datePicker.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Layout.DatePicker.ContentPadding.top
            ),
            datePicker.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Layout.DatePicker.ContentPadding.bottom
            ),
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ dirtyRect: NSRect) {
        let borderRect = bounds.insetBy(dx: Layout.DatePicker.borderInset, dy: Layout.DatePicker.borderInset)
        let border = NSBezierPath(
            roundedRect: borderRect,
            xRadius: Layout.DatePicker.cornerRadius,
            yRadius: Layout.DatePicker.cornerRadius
        )
        NSColor.controlBackgroundColor.setFill()
        border.fill()
        NSColor.separatorColor.setStroke()
        border.lineWidth = Layout.DatePicker.borderWidth
        border.stroke()

        super.draw(dirtyRect)
    }
}
