import Foundation
import Services
import AnytypeCore

// TODO: Move to services. Also move some helpers object details to servicess
// IOS-2275
struct Participant: Identifiable, Equatable {
    
    let id: String
    let name: String
    let icon: Icon?
    let status: ParticipantStatus
    let permission: ParticipantPermissions
    let identity: String
    let spaceId: String
    
    init(details: ObjectDetails) throws {
        self.id = details.id
        self.name = details.title
        self.icon = details.objectIconImage
        guard let status = details.participantStatusValue else {
            anytypeAssertionFailure("Participant status error", info: ["value": details.participantStatus?.description ?? "nil"])
            throw CommonError.undefined
        }
        self.status = status
        guard let permission = details.participantPermissionsValue else {
            anytypeAssertionFailure("Participant permission error", info: ["value": details.participantPermissions?.description ?? "nil"])
            throw CommonError.undefined
        }
        self.permission = permission
        self.identity = details.identity
        self.spaceId = details.spaceId
    }
}

extension Participant {
    static var subscriptionKeys: [BundledRelationKey] {
        .builder {
            BundledRelationKey.objectListKeys
            BundledRelationKey.participantStatus
            BundledRelationKey.participantPermissions
            BundledRelationKey.identity
        }
    }
}
