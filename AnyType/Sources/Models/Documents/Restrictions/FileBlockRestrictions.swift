
import BlocksModels

struct FileBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyItalic: Bool { false }
    var canApplyOtherMarkup: Bool { false }
    var canApplyBlockColor: Bool { false }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { false }
    var turnIntoStyles: [BlockToolbar.BlocksTypes] {
        []
    }
    var availableAlignments: [BlockInformationAlignment] {
        []
    }
}
