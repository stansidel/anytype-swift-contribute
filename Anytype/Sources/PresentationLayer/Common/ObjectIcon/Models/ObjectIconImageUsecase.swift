import Foundation
import UIKit

//@see https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=123%3A981
enum ObjectIconImageUsecase: Equatable, Hashable {
    case openedObject
    case openedObjectNavigationBar
    
    case editorSearch // slash menu + mention
    case editorSearchExpandedIcons
    case editorCalloutBlock
    case linkToObject
    
    case dashboardList
    case dashboardProfile
    case dashboardSearch
    case mention(ObjectIconImageMentionType)
    case editorAccessorySearch
    
    case featuredRelationsBlock
    
    case setRow
    case setCollection
}

extension ObjectIconImageUsecase {
    var profileBackgroundColor: UIColor {
        switch self {
        case .openedObject: return .strokePrimary
        default: return .strokeSecondary
        }
    }
    
    var placeholderBackgroundColor: UIColor {
        .strokeTransperent
    }
    
    var emojiBackgroundColor: UIColor {
        switch self {
        case .openedObjectNavigationBar, .mention, .setRow, .featuredRelationsBlock, .editorCalloutBlock:
            return .clear
        default:
            return .strokeTransperent
        }
    }
}
