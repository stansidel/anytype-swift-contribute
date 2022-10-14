import Foundation
import UIKit
import BlocksModels

protocol EditorPageCoordinatorProtocol: AnyObject {
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool)
}

final class EditorPageCoordinator: EditorPageCoordinatorProtocol {
    
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let editorAssembly: EditorAssembly
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController?,
        editorAssembly: EditorAssembly
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.editorAssembly = editorAssembly
    }
    
    // MARK: - EditorPageCoordinatorProtocol
    
    func startFlow(data: EditorScreenData, replaceCurrentPage: Bool) {
        if let details = ObjectDetailsStorage.shared.get(id: data.pageId) {
            guard ObjectTypeProvider.shared.isSupported(typeUrl: details.type) else {
                showUnsupportedTypeAlert(typeUrl: details.type)
                return
            }
        }
        
        let controller = editorAssembly.buildEditorController(
            browser: rootController,
            data: data
        )
        
        if replaceCurrentPage {
            rootController?.childNavigation?.replaceLastViewController(controller, animated: false)
        } else {
            viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Private
    
    private func showUnsupportedTypeAlert(typeUrl: String) {
        let typeName = ObjectTypeProvider.shared.objectType(url: typeUrl)?.name ?? Loc.unknown
        
        AlertHelper.showToast(
            title: "Not supported type \"\(typeName)\"",
            message: "You can open it via desktop"
        )
    }
}
