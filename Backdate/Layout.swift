import AppKit

enum Layout {
    /*
     Backdate uses standard AppKit controls, but its compact composition needs
     a small set of explicit dimensions and optical adjustments. Keeping those
     values here makes the custom geometry distinct from AppKit's defaults.
     */

    enum Window {
        static let contentWidth: CGFloat = 420
    }

    enum Content {
        static let topPadding: CGFloat = 16
        static let sectionLeading: CGFloat = 16

        enum File {
            static let placeholderHeight: CGFloat = 65
            static let placeholderCornerRadius: CGFloat = 8
            static let placeholderToDateTitleSpacing: CGFloat = 20
        }

        enum Date {
            static let pickerToChangeTitleSpacing: CGFloat = 31
        }

        enum Change {
            static let optionsToAffectTitleSpacing: CGFloat = 28
        }

        enum Affect {
            static let optionsToSeparatorSpacing: CGFloat = 24
        }

        enum ActionArea {
            static let separatorHeight: CGFloat = 1
            static let buttonTopSpacing: CGFloat = 15
            static let buttonWidth: CGFloat = 86
            static let bottomPadding: CGFloat = 16
        }
    }

    enum Section {
        static let titleHorizontalOffset: CGFloat = -8
        static let titleVerticalOffset: CGFloat = 8

        enum ContentPadding {
            static let horizontal: CGFloat = 16
            static let vertical: CGFloat = 16
        }
    }

    enum RadioGroup {
        static let rowSpacing: CGFloat = 12
    }

    enum DatePicker {
        enum ContentPadding {
            static let leading: CGFloat = 6
            static let trailing: CGFloat = 6
            static let top: CGFloat = 5
            static let bottom: CGFloat = 2
        }

        static let borderInset: CGFloat = 0.5
        static let cornerRadius: CGFloat = 7
        static let borderWidth: CGFloat = 1
    }
}
