import AppKit

final class MainViewController: NSViewController {
    private var changeButtons: [NSButton] = []
    private var affectButtons: [NSButton] = []

    override func loadView() {
        let rootView = NSView()
        view = rootView

        let fileTitle = makeSectionTitle("File")
        let filePlaceholder = makeFilePlaceholder()

        let dateTitle = makeSectionTitle("New date")
        let datePicker = InsetDatePickerView()

        let changeTitle = makeSectionTitle("Change")
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

        let affectTitle = makeSectionTitle("Affect")
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

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        let updateButton = NSButton(title: "Update", target: nil, action: nil)
        updateButton.bezelStyle = .rounded
        updateButton.controlSize = .large
        updateButton.keyEquivalent = "\r"
        updateButton.translatesAutoresizingMaskIntoConstraints = false

        [
            fileTitle,
            filePlaceholder,
            dateTitle,
            datePicker,
            changeTitle,
            changeGroup,
            affectTitle,
            affectGroup,
            separator,
            updateButton,
        ].forEach(rootView.addSubview)

        NSLayoutConstraint.activate([
            fileTitle.topAnchor.constraint(equalTo: rootView.topAnchor, constant: Layout.Content.topPadding),
            fileTitle.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.sectionLeading),

            filePlaceholder.topAnchor.constraint(
                equalTo: fileTitle.bottomAnchor,
                constant: Layout.Content.File.titleToPlaceholderSpacing
            ),
            filePlaceholder.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.sectionLeading),
            filePlaceholder.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.sectionLeading),
            filePlaceholder.heightAnchor.constraint(equalToConstant: Layout.Content.File.placeholderHeight),

            dateTitle.topAnchor.constraint(
                equalTo: filePlaceholder.bottomAnchor,
                constant: Layout.Content.File.placeholderToDateTitleSpacing
            ),
            dateTitle.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.sectionLeading),

            datePicker.topAnchor.constraint(
                equalTo: dateTitle.bottomAnchor,
                constant: Layout.Content.Date.titleToPickerSpacing
            ),
            datePicker.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.Date.pickerLeading),

            changeTitle.topAnchor.constraint(
                equalTo: datePicker.bottomAnchor,
                constant: Layout.Content.Date.pickerToChangeTitleSpacing
            ),
            changeTitle.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.sectionLeading),

            changeGroup.topAnchor.constraint(
                equalTo: changeTitle.bottomAnchor,
                constant: Layout.Content.Change.titleToOptionsSpacing
            ),
            changeGroup.leadingAnchor.constraint(
                equalTo: changeTitle.leadingAnchor,
                constant: Layout.RadioGroup.leadingIndent
            ),
            changeGroup.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.sectionLeading),

            affectTitle.topAnchor.constraint(
                equalTo: changeGroup.bottomAnchor,
                constant: Layout.Content.Change.optionsToAffectTitleSpacing
            ),
            affectTitle.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Layout.Content.sectionLeading),

            affectGroup.topAnchor.constraint(
                equalTo: affectTitle.bottomAnchor,
                constant: Layout.Content.Affect.titleToOptionsSpacing
            ),
            affectGroup.leadingAnchor.constraint(
                equalTo: affectTitle.leadingAnchor,
                constant: Layout.RadioGroup.leadingIndent
            ),
            affectGroup.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.sectionLeading),

            separator.topAnchor.constraint(
                equalTo: affectGroup.bottomAnchor,
                constant: Layout.Content.Affect.optionsToSeparatorSpacing
            ),
            separator.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: Layout.Content.ActionArea.separatorHeight),

            updateButton.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: Layout.Content.ActionArea.buttonTopSpacing),
            updateButton.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -Layout.Content.sectionLeading),
            updateButton.widthAnchor.constraint(equalToConstant: Layout.Content.ActionArea.buttonWidth),
        ])
    }

    private func makeSectionTitle(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: Layout.SectionTitle.pointSize, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeFilePlaceholder() -> NSBox {
        let box = NSBox()
        box.boxType = .custom
        box.titlePosition = .noTitle
        box.borderWidth = 0
        box.fillColor = .quaternarySystemFill
        box.cornerRadius = Layout.Content.File.placeholderCornerRadius
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
    }

    private func makeRadioButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(radioButtonWithTitle: title, target: self, action: action)
        button.font = .systemFont(ofSize: Layout.RadioGroup.buttonPointSize)
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
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.DatePicker.leadingInset),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.DatePicker.trailingInset),
            datePicker.topAnchor.constraint(equalTo: topAnchor, constant: Layout.DatePicker.topInset),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.DatePicker.bottomInset),
        ])

        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: NSSize {
        let pickerSize = datePicker.intrinsicContentSize
        return NSSize(
            width: pickerSize.width + Layout.DatePicker.intrinsicWidthAdjustment,
            height: max(
                pickerSize.height + Layout.DatePicker.intrinsicHeightAdjustment,
                Layout.DatePicker.minimumHeight
            )
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

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
    }
}
