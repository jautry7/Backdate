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
        static let sectionLeading: CGFloat = 16

        enum File {
            static let titleTop: CGFloat = 16
            static let placeholderTop: CGFloat = 40
            static let placeholderHeight: CGFloat = 65
            static let placeholderCornerRadius: CGFloat = 8
        }

        enum Date {
            static let titleTop: CGFloat = 125
            static let pickerTop: CGFloat = 145
            static let pickerLeading: CGFloat = 24
        }

        enum Change {
            static let titleTop: CGFloat = 205
            static let optionsTop: CGFloat = 229
            static let optionsHeight: CGFloat = 60
        }

        enum Affect {
            static let titleTop: CGFloat = 309
            static let optionsTop: CGFloat = 333
            static let optionsHeight: CGFloat = 90
        }

        enum ActionArea {
            static let separatorTop: CGFloat = 439
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
        static let buttonLeading: CGFloat = 8
        static let firstButtonTop: CGFloat = 4
        static let rowPitch: CGFloat = 30
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
