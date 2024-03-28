import ProtobufMessages
import Foundation


public protocol MembershipServiceProtocol {
    func getStatus() async throws -> MembershipStatus
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tier: MembershipTierId) async throws
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = data.email
            $0.subscribeToNewsletter = data.subscribeToNewsletter
        }).invoke()
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await ClientCommands.membershipVerifyEmailCode(.with {
            $0.code = code
        }).invoke()
    }
    
    public func getStatus() async throws -> MembershipStatus {
        return try await ClientCommands.membershipGetStatus().invoke().data.asModel()
    }
    
    public func validateName(name: String, tier: MembershipTierId) async throws {        
        try await ClientCommands.membershipIsNameValid(.with {
            $0.requestedAnyName = name
            $0.requestedTier = tier.middlewareId
        }).invoke(ignoreLogErrors: .hasInvalidChars, .tooLong, .tooShort)
    }
}

// MARK: - Models
public extension Anytype_Model_Membership {
    func asModel() -> MembershipStatus {
        MembershipStatus(
            tierId: MembershipTierId,
            status: status,
            dateEnds: Date(timeIntervalSince1970: TimeInterval(dateEnds)),
            paymentMethod: paymentMethod,
            anyName: requestedAnyName
        )
    }
    
    var MembershipTierId: MembershipTierId? {
        switch tier {
        case 0:
            nil
        case 1:
            .explorer
        case 4:
            .builder
        case 5:
            .coCreator
        default:
            .custom(id: tier)
        }
    }
}

// TODO: Use API
extension MembershipTierId {
    var middlewareId: Int32 {
        switch self {
        case .explorer:
            1
        case .builder:
            4
        case .coCreator:
            5
        case .custom(let id):
            id
        }
    }
}
