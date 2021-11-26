import Foundation
import BlocksModels
import Combine

protocol EditorPageViewModelProtocol {
    var blocksSelectionManager: EditorPageBlocksStateManagerProtocol { get }

    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: BlockViewModelsHolder { get }
    var actionHandler: BlockActionHandlerProtocol { get }

    var editorEditingState: AnyPublisher<EditorEditingState, Never> { get }
    
    func viewLoaded()
    func viewAppeared()

    func canSelectBlock(at indexPath: IndexPath) -> Bool
    func didSelectBlock(at indexPath: IndexPath)
    func didLongTap(at indexPath: IndexPath)
    
    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
