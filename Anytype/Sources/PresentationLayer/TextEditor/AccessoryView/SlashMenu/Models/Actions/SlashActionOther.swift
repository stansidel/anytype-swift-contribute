import BlocksModels
import AnytypeCore

enum SlashActionOther: CaseIterable {
    case lineDivider
    case dotsDivider
    case tableOfContents
    
    var title: String {
        switch self {
        case .dotsDivider:
            return "Dots divider".localized
        case .lineDivider:
            return "Line divider".localized
        case .tableOfContents:
            return "Table of contents".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .dotsDivider:
            return ImageName.slashMenu.other.dots_divider
        case .lineDivider:
            return ImageName.slashMenu.other.line_divider
        case .tableOfContents:
            return ImageName.slashMenu.other.table_of_contents
        }
    }
    
    var blockViewsType: BlockContentType {
        switch self {
        case .dotsDivider:
            return .divider(.dots)
        case .lineDivider:
            return .divider(.line)
        case .tableOfContents:
            return .tableOfContents
        }
    }
    
    static var allCases: Self.AllCases {
        if FeatureFlags.isTableOfContentsAvailable {
            return [.lineDivider, .dotsDivider, .tableOfContents]
        } else {
            return [.lineDivider, .dotsDivider]
        }
    }
}
