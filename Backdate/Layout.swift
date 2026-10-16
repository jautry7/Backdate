import AppKit

enum Layout {
    /*
     Backdate uses standard AppKit controls, but its compact composition needs
     a small set of explicit dimensions and optical adjustments. Keeping those
     values here makes the custom geometry distinct from AppKit's defaults.
     */

    enum Window {
        static let contentWidth: CGFloat = 480
    }

    enum Content {
        static let topPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 22
        static let horizontalPadding: CGFloat = 16
        static let boxBottomMargin: CGFloat = 24
        static let boxBottomMarginLast: CGFloat = 20

        enum File {
            static let dropAreaHeight: CGFloat = 64
            static let borderWidth: CGFloat = 1
            static let dashLength: CGFloat = 4
            static let dashSpacing: CGFloat = 4
            static let horizontalPadding: CGFloat = 16
            static let itemSpacing: CGFloat = 16
            static let iconSize: CGFloat = 32
        }

    }

    enum Section {
        static let titleHorizontalOffset: CGFloat = -8
        static let titleVerticalOffset: CGFloat = 10

        enum ContentPadding {
            static let horizontal: CGFloat = 18
            static let vertical: CGFloat = 18
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
