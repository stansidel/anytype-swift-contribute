import Foundation
import AnytypeCore
import Services

protocol RelationValueInteractorProtocol {
    func canHandleRelation(_ relation: Relation) -> Bool
}

final class RelationValueInteractor: RelationValueInteractorProtocol {
    
    func canHandleRelation(_ relation: Relation) -> Bool {
        if FeatureFlags.newDateRelationCalendarView, case .date = relation, relation.isEditable  {
            return true
        }
        
        if FeatureFlags.newSelectRelationView, case .status = relation {
            return true
        }
        
        if FeatureFlags.newMultiSelectRelationView, case .tag = relation {
            return true
        }
        
        if FeatureFlags.newObjectSelectRelationView, case .object = relation {
            return true
        }
        
        if FeatureFlags.newFileSelectRelationView, case .file = relation {
            return true
        }
        
        return false
    }
}
