import UIKit
import Services
import SafariServices
import SwiftUI
import FloatingPanel
import AnytypeCore

final class EditorRouter: NSObject, EditorRouterProtocol, ObjectSettingsCoordinatorOutput {
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let navigationContext: NavigationContextProtocol
    private let fileCoordinator: FileDownloadingCoordinator
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let document: BaseDocumentProtocol
    private let templatesCoordinator: TemplatesCoordinatorProtocol
    private let setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol
    private let urlOpener: URLOpenerProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let codeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let textIconPickerModuleAssembly: TextIconPickerModuleAssemblyProtocol
    private let alertHelper: AlertHelper
    private let templateService: TemplatesServiceProtocol
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        navigationContext: NavigationContextProtocol,
        document: BaseDocumentProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        templatesCoordinator: TemplatesCoordinatorProtocol,
        setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol,
        urlOpener: URLOpenerProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        toastPresenter: ToastPresenterProtocol,
        codeLanguageListModuleAssembly: CodeLanguageListModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        textIconPickerModuleAssembly: TextIconPickerModuleAssemblyProtocol,
        alertHelper: AlertHelper,
        templateService: TemplatesServiceProtocol
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.navigationContext = navigationContext
        self.document = document
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.templatesCoordinator = templatesCoordinator
        self.setObjectCreationSettingsCoordinator = setObjectCreationSettingsCoordinator
        self.urlOpener = urlOpener
        self.relationValueCoordinator = relationValueCoordinator
        self.editorPageCoordinator = editorPageCoordinator
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
        self.searchModuleAssembly = searchModuleAssembly
        self.toastPresenter = toastPresenter
        self.codeLanguageListModuleAssembly = codeLanguageListModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.textIconPickerModuleAssembly = textIconPickerModuleAssembly
        self.alertHelper = alertHelper
        self.templateService = templateService
    }

    func showPage(objectId: String) {
        guard let details = document.detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        guard !details.isDeleted else { return }
        
        showPage(data: details.editorScreenData())
    }
    
    func showPage(data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
    }

    func replaceCurrentPage(with data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: true)
    }
    
    func showAlert(alertModel: AlertModel) {
        let alertController = AlertsFactory.alertController(from: alertModel)
        navigationContext.present(alertController)
    }
    
    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters) {
        let contextualMenuView = EditorContextualMenuView(
            options: [.pasteAsLink, .createBookmark, .pasteAsText],
            optionTapHandler: { [weak self] option in
                self?.navigationContext.dismissTopPresented(animated: false)
                inputParameters.optionHandler(option)
            }
        )

        let hostViewController = UIHostingController(rootView: contextualMenuView)
        hostViewController.modalPresentationStyle = .popover

        hostViewController.preferredContentSize = hostViewController
            .sizeThatFits(in: hostViewController.view.bounds.size)

        if let popoverPresentationController = hostViewController.popoverPresentationController {
            popoverPresentationController.sourceRect = inputParameters.rect
            popoverPresentationController.sourceView = inputParameters.textView
            popoverPresentationController.delegate = self
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            navigationContext.present(hostViewController)
        }
    }
    
    func openUrl(_ url: URL) {
        urlOpener.openUrl(url)
    }
    
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ()) {
        showURLInputViewController { url in
            guard let url = url else { return }
            completion(url)
        }
    }
    
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void) {
        showURLInputViewController(url: url, completion: completion)
    }
    
    func showFilePicker(model: Picker.ViewModel) {
        let vc = Picker(model)
        navigationContext.present(vc)
    }
    
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void) {
        let vc = UIHostingController(
            rootView: MediaPickerView(
                contentType: contentType,
                onSelect: onSelect
            )
        )
        navigationContext.present(vc)
    }
    
    func saveFile(fileURL: URL, type: FileContentType) {
        fileCoordinator.downloadFileAt(fileURL, withType: type)
    }
    
    func showCodeLanguage(blockId: BlockId, selectedLanguage: CodeLanguage) {
        if FeatureFlags.newCodeLanguages {
            let module = codeLanguageListModuleAssembly.make(document: document, blockId: blockId, selectedLanguage: selectedLanguage)
            navigationContext.present(module)
        } else {
            let moduleViewController = codeLanguageListModuleAssembly.makeLegacy(document: document, blockId: blockId)
            navigationContext.present(moduleViewController)
        }
    }
    
    func showStyleMenu(
        informations: [BlockInformation],
        restrictions: BlockRestrictions,
        didShow: @escaping (UIView) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let infos = informations.compactMap { document.infoContainer.get(id: $0.id) }
        guard
            let controller = viewController,
            let rootController = rootController,
            infos.isNotEmpty
        else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller", info: ["controller": "\(controller)"])
            return
        }

        let popup = BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: rootController,
            infos: infos,
            actionHandler: controller.viewModel.actionHandler,
            restrictions: restrictions,
            showMarkupMenu: { [weak controller, weak rootController, weak self] styleView, viewDidClose in
                guard let self = self else { return }
                guard let controller = controller else { return }
                guard let rootController = rootController else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: rootController,
                    styleView: styleView,
                    document: self.document,
                    blockIds: infos.map { $0.id },
                    actionHandler: controller.viewModel.actionHandler,
                    linkToObjectCoordinator: self.linkToObjectCoordinator,
                    viewDidClose: viewDidClose
                )
            },
            onDismiss: onDismiss
        )

        guard let popup = popup else {
            return
        }

        popup.addPanel(toParent: controller, animated: true) {
            didShow(popup.surfaceView)
        }
    }
    
    func showMoveTo(onSelect: @escaping (ObjectDetails) -> ()) {
        
        let moveToView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.moveTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: [.set, .collection]
        ) { [weak self] details in
            onSelect(details)
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.present(moveToView)
    }

    func showLinkTo(onSelect: @escaping (ObjectDetails) -> ()) {
        let moduleView = newSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            spaceId: document.spaceId,
            excludedObjectIds: [document.objectId],
            excludedLayouts: []
        ) { [weak self] details in
            onSelect(details)
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.presentSwiftUIView(view: moduleView)
    }

    func showTextIconPicker(contextId: BlockId, objectId: BlockId) {
        let moduleView = textIconPickerModuleAssembly.make(
            contextId: contextId,
            objectId: objectId,
            // In feature space id should be read from blockInfo, when we will create "link to" between sapces
            spaceId: document.spaceId,
            onDismiss: { [weak self] in
                self?.navigationContext.dismissTopPresented()
            }
        )

        navigationContext.present(moduleView)
    }
    
    func showSearch(onSelect: @escaping (EditorScreenData) -> ()) {
        let module = searchModuleAssembly.makeObjectSearch(
            data: SearchModuleModel(
                spaceId: document.spaceId,
                title: nil,
                onSelect: { data in
                    onSelect(data.editorScreenData)
                }
            )
        )
        navigationContext.present(module)
    }
    
    func showTypes(selectedObjectId: BlockId?, onSelect: @escaping (ObjectType) -> ()) {
        showTypesSearch(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            showBookmark: false,
            showSetAndCollection: false,
            onSelect: onSelect
        )
    }
    
    func showTypesForEmptyObject(
        selectedObjectId: BlockId?,
        onSelect: @escaping (ObjectType) -> ()
    ) {
        showTypesSearch(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            showBookmark: false,
            showSetAndCollection: true,
            onSelect: onSelect
        )
    }
    
    func showWaitingView(text: String) {
        let popup = PopupViewBuilder.createWaitingPopup(text: text)
        navigationContext.present(popup)
    }

    func hideWaitingView() {
        navigationContext.dismissTopPresented()
    }
    
    func closeEditor() {
        guard let viewController else { return }
        rootController?.popIfPresent(viewController)
    }
    
    func presentSheet(_ vc: UIViewController) {
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
        navigationContext.present(vc)
    }
    
    func presentFullscreen(_ vc: UIViewController) {
        navigationContext.present(vc)
    }
    
    @MainActor
    func showObjectPreview(
        blockLinkState: BlockLinkState,
        onSelect: @escaping (BlockLink.Appearance) -> Void
    ) {
        let router = ObjectPreviewRouter(viewController: viewController)
        let viewModel = ObjectPreviewViewModel(
            blockLinkState: blockLinkState,
            router: router,
            onSelect: onSelect
        )

        let contentView = ObjectPreviewView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: contentView)

        navigationContext.present(popup)

    }

    // MARK: - Settings
    func showSettings(actionHandler: @escaping (ObjectSettingsAction) -> Void) {
        objectSettingCoordinator.startFlow(
            objectId: document.objectId,
            delegate: self,
            output: self,
            objectSettingsHandler: actionHandler
        )
    }
    
    func showCoverPicker(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    ) {
        let moduleViewController = objectCoverPickerModuleAssembly.make(
            document: document,
            onCoverAction: onCoverAction
        )
        navigationContext.present(moduleViewController)
    }
    
    func showIconPicker(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document, onIconAction: onIconAction)
        navigationContext.present(moduleViewController)
    }

    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    ) {
        guard let rootController = rootController else { return }

        let styleColorViewController = StyleColorViewController(
            selectedColor: selectedColor,
            selectedBackgroundColor: selectedBackgroundColor,
            onColorSelection: onColorSelection) { viewController in
                viewController.removeFromParentEmbed()
            }

        rootController.embedChild(styleColorViewController)

        styleColorViewController.view.pinAllEdges(to: rootController.view)
        styleColorViewController.colorView.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.centerX.equal(to: rootController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: rootController.view.bottomAnchor, constant: -50)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func showMarkupBottomSheet(
        selectedBlockIds: [BlockId],
        viewDidClose: @escaping () -> Void
    ) {
        guard let controller = viewController,
            let rootController = rootController else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller", info: ["controller": "\(controller)"])
            return
        }
        
        let viewModel = MarkupViewModel(
            document: document,
            blockIds: selectedBlockIds,
            actionHandler: controller.viewModel.actionHandler,
            linkToObjectCoordinator: linkToObjectCoordinator
        )
        let viewController = MarkupsViewController(
            viewModel: viewModel,
            viewDidClose: viewDidClose
        )

        viewModel.view = viewController

        rootController.embedChild(viewController)

        viewController.view.pinAllEdges(to: rootController.view)
        viewController.containerShadowView.layoutUsing.anchors {
            $0.width.equal(to: 240)
            $0.height.equal(to: 158)
            $0.centerX.equal(to: rootController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: rootController.view.bottomAnchor, constant: -50)
        }
    }
    
    func showFailureToast(message: String) {
        toastPresenter.showFailureAlert(message: message)
    }
    
    @MainActor
    func showTemplatesPicker() {
        templatesCoordinator.showTemplatesPicker(document: document)
    }
    
    @MainActor
    func showOpenDocumentError(error: Error) {
        let alert = AlertsFactory.objectOpenErrorAlert(error: error) { [weak self] in
            self?.closeEditor()
        }
        navigationContext.present(alert)
    }
    
    // MARK: - Private
    
    private func showURLInputViewController(
        url: AnytypeURL? = nil,
        completion: @escaping(AnytypeURL?) -> Void
    ) {
        let controller = URLInputViewController(url: url, didSetURL: completion)
        controller.modalPresentationStyle = .overCurrentContext
        navigationContext.present(controller, animated: false)
    }
    
    private func showTypesSearch(
        title: String,
        selectedObjectId: BlockId?,
        showBookmark: Bool,
        showSetAndCollection: Bool,
        onSelect: @escaping (ObjectType) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: title,
            spaceId: document.spaceId,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: document.details?.type,
            showBookmark: showBookmark,
            showSetAndCollection: showSetAndCollection,
            browser: rootController
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
}

extension EditorRouter: AttachmentRouterProtocol {
    func openImage(_ imageContext: FilePreviewContext) {
        let previewController = AnytypePreviewController(with: [imageContext.file], sourceView: imageContext.sourceView, onContentChanged: imageContext.onDidEditFile)

        navigationContext.present(previewController) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
    }
}

// MARK: - Relations
extension EditorRouter {
    func showRelationValueEditingView(key: String) {
        let relation = document.parsedRelations.installed.first { $0.key == key }
        guard let relation = relation else { return }
        
        showRelationValueEditingView(objectId: document.objectId, relation: relation)
    }
    
    func showRelationValueEditingView(objectId: BlockId, relation: Relation) {
        guard let objectDetails = document.detailsStorage.get(id: objectId) else {
            anytypeAssertionFailure("Details not found")
            return
        }
        relationValueCoordinator.startFlow(objectDetails: objectDetails, relation: relation, analyticsType: .block, output: self)
    }

    func showAddNewRelationView(
        document: BaseDocumentProtocol,
        onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?
    ) {
        addNewRelationCoordinator.showAddNewRelationView(
            document: document,
            excludedRelationsIds: document.parsedRelations.installed.map(\.id),
            target: .object,
            onCompletion: onSelect
        )
    }
}

extension EditorRouter: RelationValueCoordinatorOutput {
    func openObject(screenData: EditorScreenData) {
        navigationContext.dismissAllPresented()
        showPage(data: screenData)
    }
}

extension EditorRouter: ObjectSettingsModuleDelegate {
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: data.objectId) { [weak self] in
            self?.showPage(data: data)
        }
    }
    
    @MainActor
    func didCreateTemplate(templateId: BlockId) {
        guard let objectType = document.details?.objectType else { return }
        let setting = ObjectCreationSetting(objectTypeId: objectType.id, spaceId: document.spaceId, templateId: templateId)
        setObjectCreationSettingsCoordinator.showTemplateEditing(
            setting: setting,
            onTemplateSelection: nil,
            onSetAsDefaultTempalte: { [weak self] templateId in
                self?.didTapUseTemplateAsDefault(templateId: templateId)
            }, 
            completion: { [weak self] in
                self?.toastPresenter.showObjectCompositeAlert(
                    prefixText: Loc.Templates.Popup.wasAddedTo,
                    objectId: objectType.id,
                    tapHandler: { }
                )
            }
        )
    }
    
    func didTapUseTemplateAsDefault(templateId: BlockId) {
        Task { @MainActor in
            try? await templateService.setTemplateAsDefaultForType(templateId: templateId)
            navigationContext.dismissTopPresented(animated: true, completion: nil)
            toastPresenter.show(message: Loc.Templates.Popup.default)
        }
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension EditorRouter: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
