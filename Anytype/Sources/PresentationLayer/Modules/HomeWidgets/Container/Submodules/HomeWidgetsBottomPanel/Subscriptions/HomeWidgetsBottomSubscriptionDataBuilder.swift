import Foundation
import BlocksModels

protocol HomeWidgetsBottomSubscriptionDataBuilderProtocol {
    func build(objectId: String) -> SubscriptionData
}

fileprivate extension SubscriptionId {
    static var homeBottom = SubscriptionId(value: "HomeWidgetsBottomSubscription")
}

final class HomeWidgetsBottomSubscriptionDataBuilder: HomeWidgetsBottomSubscriptionDataBuilderProtocol {
    
    // MARK: - HomeWidgetsBottomSubscriptionDataBuilderProtocol
    
    func build(objectId: String) -> SubscriptionData {
        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.snippet.rawValue,
            BundledRelationKey.links.rawValue,
            BundledRelationKey.type.rawValue,
            BundledRelationKey.layout.rawValue,
            BundledRelationKey.iconImage.rawValue,
            BundledRelationKey.iconEmoji.rawValue,
            BundledRelationKey.isDeleted.rawValue,
            BundledRelationKey.isArchived.rawValue,
        ]
        
        return .objects(
            SubscriptionData.Object(
                identifier: .homeBottom,
                objectIds: [objectId],
                keys: keys
            )
        )
    }
}
