import Foundation
import BlocksModels
import SwiftProtobuf

protocol RelationsServiceProtocol {
    func addFeaturedRelation(relationKey: String)
    func removeFeaturedRelation(relationKey: String)
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value)

    func addRelation(_ relation: RelationMetadata, isNew: Bool) -> RelationMetadata?
    func removeRelation(relationKey: String)
    func addRelationOption(relationKey: String, optionText: String) -> String?
    func availableRelations() -> [RelationMetadata]?
}
