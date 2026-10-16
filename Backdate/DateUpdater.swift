import Foundation

enum DateChangeMode: Sendable {
    case createdAndModified
    case createdOnly
    case modifiedOnly
}

enum ItemScope: Sendable {
    case selectedItem
    case nextLevel
    case allDescendants
}

struct DateUpdateFailure: Sendable {
    let url: URL
    let message: String
}

struct DateUpdateResult: Sendable {
    let updatedCount: Int
    let failures: [DateUpdateFailure]
}

enum DateUpdater {
    nonisolated static func update(
        url: URL,
        date: Date,
        mode: DateChangeMode,
        scope: ItemScope
    ) -> DateUpdateResult {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let fileManager = FileManager.default
        var (items, failures) = items(
            for: url,
            scope: scope,
            fileManager: fileManager
        )
        var updatedCount = 0

        var attributes: [FileAttributeKey: Any] = [:]
        switch mode {
        case .createdAndModified:
            attributes[.creationDate] = date
            attributes[.modificationDate] = date
        case .createdOnly:
            attributes[.creationDate] = date
        case .modifiedOnly:
            attributes[.modificationDate] = date
        }

        for item in items.reversed() {
            do {
                try fileManager.setAttributes(attributes, ofItemAtPath: item.path)
                updatedCount += 1
            } catch {
                failures.append(
                    DateUpdateFailure(url: item, message: error.localizedDescription)
                )
            }
        }

        return DateUpdateResult(updatedCount: updatedCount, failures: failures)
    }

    nonisolated private static func items(
        for rootURL: URL,
        scope: ItemScope,
        fileManager: FileManager
    ) -> ([URL], [DateUpdateFailure]) {
        if case .selectedItem = scope {
            return ([rootURL], [])
        }

        do {
            let values = try rootURL.resourceValues(
                forKeys: [.isDirectoryKey, .isSymbolicLinkKey]
            )
            guard values.isDirectory == true, values.isSymbolicLink != true else {
                return ([rootURL], [])
            }
        } catch {
            return (
                [rootURL],
                [DateUpdateFailure(url: rootURL, message: error.localizedDescription)]
            )
        }

        switch scope {
        case .selectedItem:
            return ([rootURL], [])

        case .nextLevel:
            do {
                let children = try fileManager.contentsOfDirectory(
                    at: rootURL,
                    includingPropertiesForKeys: nil
                )
                return ([rootURL] + children, [])
            } catch {
                return (
                    [rootURL],
                    [DateUpdateFailure(url: rootURL, message: error.localizedDescription)]
                )
            }

        case .allDescendants:
            var items = [rootURL]
            var failures: [DateUpdateFailure] = []
            guard let enumerator = fileManager.enumerator(
                at: rootURL,
                includingPropertiesForKeys: [.isSymbolicLinkKey],
                options: [],
                errorHandler: { url, error in
                    failures.append(
                        DateUpdateFailure(url: url, message: error.localizedDescription)
                    )
                    return true
                }
            ) else {
                return ([rootURL], [])
            }

            while let itemURL = enumerator.nextObject() as? URL {
                items.append(itemURL)
                if (try? itemURL.resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink == true {
                    enumerator.skipDescendants()
                }
            }

            return (items, failures)
        }
    }
}
