import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(ObjectHeaderFilledState)
    case empty(ObjectHeaderEmptyData)
    
    static var initialState: ObjectHeader {
        .empty(.init(onTap: {}))
    }
}
extension ObjectHeader: ContentConfigurationProvider {
    var hashable: AnyHashable {
        hashValue as AnyHashable
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {

    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case .filled(let filledState):
            return ObjectHeaderFilledConfiguration(state: filledState, width: maxWidth)
        case .empty(let data):
            return ObjectHeaderEmptyConfiguration(data: data)
        }
    }
    
}
