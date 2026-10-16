import AppKit

enum Layout {
    /*
     Backdate uses standard AppKit controls, but its compact composition needs
     a small set of explicit dimensions and optical adjustments. Keeping those
     values here makes the custom geometry distinct from AppKit's defaults.
     */

    enum Window {
        static let contentSize = NSSize(width: 424, height: 507)
        static let frameSize = NSSize(width: 424, height: 559)
        static let titlePointSize: CGFloat = 13
    }

    enum Content {
        static let topPadding: CGFloat = 16
        static let sectionLeading: CGFloat = 16

        enum File {
            static let titleToPlaceholderSpacing: CGFloat = 8
            static let placeholderHeight: CGFloat = 65
            static let placeholderCornerRadius: CGFloat = 8
            static let placeholderToDateTitleSpacing: CGFloat = 20
        }

        enum Date {
            static let titleToPickerSpacing: CGFloat = 4
            static let pickerLeading: CGFloat = 24
            static let pickerToChangeTitleSpacing: CGFloat = 31
        }

        enum Change {
            static let titleToOptionsSpacing: CGFloat = 12
            static let optionsToAffectTitleSpacing: CGFloat = 28
        }

        enum Affect {
            static let titleToOptionsSpacing: CGFloat = 12
            static let optionsToSeparatorSpacing: CGFloat = 24
        }

        enum ActionArea {
            static let separatorHeight: CGFloat = 1
            static let buttonTopSpacing: CGFloat = 15
            static let buttonWidth: CGFloat = 86
        }
    }

    enum SectionTitle {
        static let pointSize: CGFloat = 13
    }

    enum RadioGroup {
        static let buttonPointSize: CGFloat = 13
        static let leadingIndent: CGFloat = 8
        static let rowSpacing: CGFloat = 12
    }

    enum DatePicker {
        static let leadingInset: CGFloat = 4
        static let trailingInset: CGFloat = 1
        static let topInset: CGFloat = 4
        static let bottomInset: CGFloat = 1

        static let intrinsicWidthAdjustment: CGFloat = 12
        static let intrinsicHeightAdjustment: CGFloat = 7
        static let minimumHeight: CGFloat = 29

        static let borderInset: CGFloat = 0.5
        static let cornerRadius: CGFloat = 7
        static let borderWidth: CGFloat = 1
    }
}
