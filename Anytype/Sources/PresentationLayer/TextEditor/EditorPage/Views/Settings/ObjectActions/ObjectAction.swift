import Services
import AnytypeCore

enum ObjectAction: Hashable, Identifiable {
    // NOTE: When adding new case here, it case MUST be added in allCasesWith method
    case undoRedo
    case archive(isArchived: Bool)
    case favorite(isFavorite: Bool)
    case locked(isLocked: Bool)
    case duplicate
    case linkItself
    case makeAsTemplate
    case templateSetAsDefault
    case delete
    case createWidget

    // When adding to case
    static func allCasesWith(
        details: ObjectDetails,
        isLocked: Bool,
        permissions: ObjectPermissions
    ) -> [Self] {
        .builder {
            if permissions.canDelete {
                ObjectAction.delete
            }
            
            if permissions.canArchive {
                ObjectAction.archive(isArchived: details.isArchived)
            }
            
            if permissions.canTemplateSetAsDefault {
                ObjectAction.templateSetAsDefault
            }
            
            if permissions.canDuplicate {
                ObjectAction.duplicate
            }
            
            if permissions.canUndoRedo {
                ObjectAction.undoRedo
            }
            
            if permissions.canCreateWidget {
                ObjectAction.createWidget
            }
            
            if permissions.canFavorite {
                ObjectAction.favorite(isFavorite: details.isFavorite)
            }
            
            if permissions.canMakeAsTemplate {
                ObjectAction.makeAsTemplate
            }
            
            if permissions.canLinkItself {
                ObjectAction.linkItself
            }
            
            if permissions.canLock {
                ObjectAction.locked(isLocked: isLocked)
            }
        }
    }
    
    var id: String {
        switch self {
        case .undoRedo:
            return "undoredo"
        case .archive:
            return "archive"
        case .favorite:
            return "favorite"
        case .locked:
            return "locked"
        case .duplicate:
            return "duplicate"
        case .linkItself:
            return "linkItself"
        case .makeAsTemplate:
            return "makeAsTemplate"
        case .templateSetAsDefault:
            return "templateSetAsDefault"
        case .delete:
            return "delete"
        case .createWidget:
            return "createWidget"
        }
    }
}
