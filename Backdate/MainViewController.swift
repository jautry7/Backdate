import AppKit

final class MainViewController: NSViewController {
    private var changeButtons: [NSButton] = []
    private var affectButtons: [NSButton] = []

    override func loadView() {
        let rootView = NSView()
        view = rootView

        let filePlaceholder = makeFilePlaceholder()
        let fileSection = makeSection(title: "File", content: filePlaceholder)

        let datePicker = InsetDatePickerView()
        let dateSpacer = NSView()
        dateSpacer.translatesAutoresizingMaskIntoConstraints = false
        let dateRow = NSStackView(views: [datePicker, dateSpacer])
        dateRow.orientation = .horizontal
        dateRow.alignment = .centerY
        dateRow.distribution = .fill
        dateRow.spacing = 0
        dateRow.translatesAutoresizingMaskIntoConstraints = false
        let dateSection = makeSection(title: "New date", content: dateRow)

        let createdAndModifiedButton = makeRadioButton(
            title: "Created & modified date",
            action: #selector(changeSelectionChanged(_:))
        )
        let modifiedOnlyButton = makeRadioButton(
            title: "Modified date only",
            action: #selector(changeSelectionChanged(_:))
        )
        changeButtons = [createdAndModifiedButton, modifiedOnlyButton]
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

        let updateButton = NSButton(title: "Update", target: nil, action: nil)
        updateButton.controlSize = .regular
        updateButton.keyEquivalent = "\r"
        updateButton.translatesAutoresizingMaskIntoConstraints = false

        [
            fileSection,
            dateSection,
            changeSection,
            affectSection,
            updateButton,
        ].forEach(rootView.addSubview)

        NSLayoutConstraint.activate([
            fileSection.topAnchor.constraint(equalTo: rootView.topAnchor, constant: Layout.Content.topPadding),
            fileSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            fileSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),
            filePlaceholder.heightAnchor.constraint(equalToConstant: Layout.Content.File.placeholderHeight),

            dateSection.topAnchor.constraint(
                equalTo: fileSection.bottomAnchor,
                constant: Layout.Content.boxBottomMargin
            ),
            dateSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            dateSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),

            changeSection.topAnchor.constraint(
                equalTo: dateSection.bottomAnchor,
                constant: Layout.Content.boxBottomMargin
            ),
            changeSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            changeSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),

            affectSection.topAnchor.constraint(
                equalTo: changeSection.bottomAnchor,
                constant: Layout.Content.boxBottomMargin
            ),
            affectSection.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.horizontalPadding),
            affectSection.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),

            updateButton.topAnchor.constraint(
                equalTo: affectSection.bottomAnchor,
                constant: Layout.Content.boxBottomMarginLast
            ),
            updateButton.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.horizontalPadding),
            updateButton.bottomAnchor.constraint(
                equalTo: rootView.bottomAnchor,
                constant: -Layout.Content.bottomPadding
            ),
        ])
    }

    private func makeSection(title: String, content: NSView) -> NSBox {
        let box = SectionBox()
        box.title = title
        box.titleFont = .preferredFont(forTextStyle: .callout)
        (box.titleCell as? NSTextFieldCell)?.textColor = .secondaryLabelColor
        box.contentViewMargins = NSSize(
            width: Layout.Section.ContentPadding.horizontal,
            height: Layout.Section.ContentPadding.vertical
        )
        box.translatesAutoresizingMaskIntoConstraints = false

        guard let contentView = box.contentView else { return box }
        contentView.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            content.topAnchor.constraint(equalTo: contentView.topAnchor),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        return box
    }

    private func makeFilePlaceholder() -> NSBox {
        let box = NSBox()
        box.boxType = .custom
        box.titlePosition = .noTitle
        box.borderWidth = 0
        box.fillColor = NSColor.labelColor.withAlphaComponent(0.04)
        box.cornerRadius = Layout.Content.File.placeholderCornerRadius
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
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
}

private final class SectionBox: NSBox {
    override var intrinsicContentSize: NSSize {
        let nativeSize = super.intrinsicContentSize
        let contentHeight = contentView?.fittingSize.height ?? 0
        let titleAllowance = max(0, titleRect.height - (borderWidth * 2))

        return NSSize(
            width: nativeSize.width,
            height: contentHeight + (contentViewMargins.height * 2) + titleAllowance
        )
    }

    override var titleRect: NSRect {
        super.titleRect.offsetBy(
            dx: Layout.Section.titleHorizontalOffset,
            dy: Layout.Section.titleVerticalOffset
        )
    }
}

private final class InsetDatePickerView: NSView {
    private let datePicker: NSDatePicker

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
        datePicker.presentsCalendarOverlay = true
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
