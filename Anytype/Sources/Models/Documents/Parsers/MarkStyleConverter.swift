import BlocksModels
import ProtobufMessages
import AnytypeCore
import UIKit

enum MarkStyleActionConverter {
    
    static func asModel(tuple: MiddlewareTuple) -> MarkupType? {
        switch tuple.attribute {
        case .strikethrough:
            return .strikethrough
        case .keyboard:
            return .keyboard
        case .italic:
            return .italic
        case .bold:
            return .bold
        case .underscored:
            return .underscored
        case .link:
            return .link(URL(string: tuple.value))

        case .textColor:
            guard let middlewareColor = MiddlewareColor(rawValue: tuple.value) else {
                return nil
            }
            return .textColor(UIColor.Text.uiColor(from: middlewareColor))

        case .backgroundColor:
            guard let middlewareColor = MiddlewareColor(rawValue: tuple.value) else {
                return nil
            }
            return .backgroundColor(UIColor.BlockBackground.uiColor(from: middlewareColor))

        case .mention:
            guard let details = ObjectDetailsStorage.shared.get(id: tuple.value) else {
                return .mention(.noDetails(blockId: tuple.value))
            }
            return .mention(MentionData(details: details))

        case .object:
            return .linkToObject(tuple.value)

        case .emoji:
            anytypeAssertionFailure("Unrecognized markup emoji", domain: .markStyleConverter)
            return nil

        case .UNRECOGNIZED(let value):
            anytypeAssertionFailure("Unrecognized markup \(value)", domain: .markStyleConverter)
            return nil
        }
    }
}
