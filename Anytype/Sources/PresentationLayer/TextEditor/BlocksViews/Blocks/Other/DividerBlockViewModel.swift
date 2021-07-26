import BlocksModels
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation
    
    private let dividerContent: BlockDivider
    private let handler: DefaultContextualMenuHandler
    
    init(content: BlockDivider, information: BlockInformation, indentationLevel: Int, handler: DefaultContextualMenuHandler) {
        self.dividerContent = content
        self.information = information
        self.indentationLevel = indentationLevel
        self.handler = handler
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent)
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        [ .addBlockBelow, .duplicate, .delete ]
    }
    
    func handle(action: ContextualMenu) {
        handler.handle(action: action, info: information)
    }
    
    func didSelectRowInTableView() {}
}
