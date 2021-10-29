import Foundation
import BlocksModels

protocol BlockActionHandlerProtocol {

    func handleBlockAction(_ action: BlockHandlerActionType, blockId: BlockId)

    func upload(blockId: BlockId, filePath: String)
    func turnIntoPage(blockId: BlockId) -> BlockId?
    func createPage(targetId: BlockId, type: String, position: BlockPosition) -> BlockId?
    func setObjectTypeUrl(_ objectTypeUrl: String)
}
