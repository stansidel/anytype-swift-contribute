import BlocksModels
import UIKit
import AnytypeCore

extension Array where Element == BlockRestrictions {
    var mergedOptions: Set<BlocksOptionItem> {
        var options = Set(BlocksOptionItem.allCases)

        forEach { element in
            if !element.canDeleteOrDuplicate {
                options.remove(.delete)
                options.remove(.duplicate)
            }

            if !element.canApplyStyle(.smartblock(.page)) {
                options.remove(.turnInto)
            }
        }

        if count > 1 {
            options.remove(.addBlockBelow)
        }

        return options
    }
}

extension Array where Element == BlockInformation {
    var blocksOptionItems: [BlocksOptionItem] {
        var isDownloadAvailable = true
        var isStyleAvailable = true
        var isOpenObjectAvailable = false
        
        var restrictions = [BlockRestrictions]()

        forEach { element in
            if case let .file(type) = element.content {
                if type.state != .done { isDownloadAvailable = false }
            } else {
                isDownloadAvailable = false
            }
            
            if case let .bookmark(bookmark) = element.content,
                bookmark.targetObjectID.isNotEmpty,
                let details = ObjectDetailsStorage.shared.get(id: bookmark.targetObjectID),
                !details.isArchived, !details.isDeleted {
                isOpenObjectAvailable = true
            }

            if !element.content.isText {
                isStyleAvailable = false
            }

            let restriction = BlockRestrictionsBuilder.build(contentType: element.content.type)
            restrictions.append(restriction)
        }

        var mergedItems = restrictions.mergedOptions

        if !isDownloadAvailable || count > 1 {
            mergedItems.remove(.download)
        }

        if !isStyleAvailable || count > 1 {
            mergedItems.remove(.style)
        }

        if !FeatureFlags.objectPreview {
            mergedItems.remove(.preview)
        }

        var isPreviewAvailable = false
        if case .link = first?.content, count == 1 {
            isPreviewAvailable = true
        }

        if !isPreviewAvailable {
            mergedItems.remove(.preview)
        }

        if !UIPasteboard.general.hasSlots {
            mergedItems.remove(.paste)
        }
        
        if !FeatureFlags.bookmarksFlow || !isOpenObjectAvailable || count > 1 {
            mergedItems.remove(.openObject)
        }

        return Array<BlocksOptionItem>(mergedItems).sorted()
    }
}
