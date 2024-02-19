import UIKit
import Services
import Combine
import AnytypeCore
import ProtobufMessages

final class BlockActionHandler: BlockActionHandlerProtocol {    
    weak var blockSelectionHandler: BlockSelectionHandler?
    private let document: BaseDocumentProtocol
    
    private let service: BlockActionServiceProtocol
    private let blockService: BlockServiceProtocol
    private let markupChanger: BlockMarkupChangerProtocol
    private let keyboardHandler: KeyboardActionHandlerProtocol
    private let blockTableService: BlockTableServiceProtocol
    private let fileService: FileActionsServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol,
        blockService: BlockServiceProtocol,
        keyboardHandler: KeyboardActionHandlerProtocol,
        blockTableService: BlockTableServiceProtocol,
        fileService: FileActionsServiceProtocol,
        objectService: ObjectActionsServiceProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
        self.blockService = blockService
        self.keyboardHandler = keyboardHandler
        self.blockTableService = blockTableService
        self.fileService = fileService
        self.objectService = objectService
    }

    // MARK: - Service proxy

    func turnIntoPage(blockId: String) async throws -> String? {
        try await service.turnIntoPage(blockId: blockId, spaceId: document.spaceId)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: String) {
        defer { AnytypeAnalytics.instance().logChangeBlockStyle(style) }
        
        switch style {
        case .toggle:
            if let blockInformation = document.infoContainer.get(id: blockId),
               blockInformation.childrenIds.count > 0, !blockInformation.isToggled {
                blockInformation.toggle()
            }
            service.turnInto(style, blockId: blockId)
        default:
            service.turnInto(style, blockId: blockId)
        }
    }
    
    func upload(blockId: String, filePath: String) async throws {
        try await service.upload(blockId: blockId, filePath: filePath)
    }
    
    @MainActor
    func setObjectType(type: ObjectType) async throws {
        if #available(iOS 17.0, *) {
            HomeCreateObjectTip.objectTpeChanged = true
        }
        try await service.setObjectType(type: type)
    }

    func setObjectSetType() async throws {
        try await service.setObjectSetType()
    }
    
    func setObjectCollectionType() async throws {
        try await service.setObjectCollectionType()
    }
    
    func applyTemplate(objectId: String, templateId: String) async throws {
        try await objectService.applyTemplate(objectId: objectId, templateId: templateId)
    }
    
    func setTextColor(_ color: BlockColor, blockIds: [String]) {
        Task {
            try await blockService.setBlockColor(objectId: document.objectId, blockIds: blockIds, color: color.middleware)
        }
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String]) {
        AnytypeAnalytics.instance().logChangeBlockBackground(color: color.middleware)
        service.setBackgroundColor(blockIds: blockIds, color: color)
    }
    
    func duplicate(blockId: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListDuplicate)
        service.duplicate(blockId: blockId)
    }
    
    func fetch(url: AnytypeURL, blockId: String) {
        service.bookmarkFetch(blockId: blockId, url: url)
    }
    
    func checkbox(selected: Bool, blockId: String) {
        service.checked(blockId: blockId, newValue: selected)
    }
    
    func toggle(blockId: String) {
        Task {
            await EventsBunch(contextId: document.objectId, localEvents: [.setToggled(blockId: blockId)])
                .send()
        }
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String]) {
        AnytypeAnalytics.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)
        Task {
            try await blockService.setAlign(objectId: document.objectId, blockIds: blockIds, alignment: alignment)
        }
    }
    
    func delete(blockIds: [String]) {
        service.delete(blockIds: blockIds)
    }
    
    func moveToPage(blockId: String, pageId: String) {
        AnytypeAnalytics.instance().logMoveBlock()
        Task {
            try await blockService.moveToPage(objectId: document.objectId, blockId: blockId, pageId: pageId)
        }
    }
    
    func createEmptyBlock(parentId: String) {
        let emptyBlock = BlockInformation.emptyText
        AnytypeAnalytics.instance().logCreateBlock(type: emptyBlock.content.type)
        service.addChild(info: emptyBlock, parentId: parentId)
    }
    
    func addLink(targetDetails: ObjectDetails, blockId: String) {
        let isBookmarkType = targetDetails.layoutValue == .bookmark
        AnytypeAnalytics.instance().logCreateLink()
        service.add(
            info: isBookmarkType ? .bookmark(targetId: targetDetails.id) : .emptyLink(targetId: targetDetails.id),
            targetBlockId: blockId,
            position: .replace
        )
    }
    
    func changeMarkup(blockIds: [String], markType: MarkupType) {
        Task {
            AnytypeAnalytics.instance().logChangeBlockStyle(markType)
            try await blockService.changeMarkup(objectId: document.objectId, blockIds: blockIds, markType: markType)
        }
    }
    
    // MARK: - Markup changer proxy
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: String) {
        guard let newText = markupChanger.toggleMarkup(markup, blockId: blockId) else { return }
        
        changeTextForced(newText, blockId: blockId)
    }
    
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: String) {
        guard let newText = markupChanger.toggleMarkup(attribute, blockId: blockId, range: range) else { return }

        AnytypeAnalytics.instance().logChangeTextStyle(attribute)

        changeTextForced(newText, blockId: blockId)
    }
    
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: String, currentText: NSAttributedString?) {
        guard let newText = markupChanger.setMarkup(attribute, blockId: blockId, range: range, currentText: currentText)
            else { return }

        AnytypeAnalytics.instance().logChangeTextStyle(attribute)

        changeTextForced(newText, blockId: blockId)
    }
    
    func setLink(url: URL?, range: NSRange, blockId: String) {
        let newText: NSAttributedString?
        AnytypeAnalytics.instance().logChangeTextStyle(MarkupType.link(url))
        if let url = url {
            newText = markupChanger.setMarkup(.link(url), blockId: blockId, range: range)
        } else {
            newText = markupChanger.removeMarkup(.link(nil), blockId: blockId, range: range)
        }
        
        guard let newText = newText else { return }
        changeTextForced(newText, blockId: blockId)
    }
    
    func setLinkToObject(linkBlockId: String?, range: NSRange, blockId: String) {
        let newText: NSAttributedString?
        AnytypeAnalytics.instance().logChangeTextStyle(MarkupType.linkToObject(linkBlockId))
        if let linkBlockId = linkBlockId {
            newText = markupChanger.setMarkup(.linkToObject(linkBlockId), blockId: blockId, range: range)
        } else {
            newText = markupChanger.removeMarkup(.linkToObject(nil), blockId: blockId, range: range)
        }
        
        guard let newText = newText else { return }
        changeTextForced(newText, blockId: blockId)
    }

    func handleKeyboardAction(
        _ action: CustomTextView.KeyboardAction,
        currentText: NSAttributedString,
        info: BlockInformation
    ) {
        keyboardHandler.handle(info: info, currentString: currentText, action: action)
    }
    
    func changeTextForced(_ text: NSAttributedString, blockId: String) {
        let safeSendableText = SafeSendable(value: text)
        
        Task {
            guard let info = document.infoContainer.get(id: blockId) else { return }
            
            guard case .text = info.content else { return }
            
            let middlewareString = AttributedTextConverter.asMiddleware(attributedText: safeSendableText.value)
            
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setText(blockId: info.id, text: middlewareString)]
            ).send()
            
            try await service.setTextForced(contextId: document.objectId, blockId: info.id, middlewareString: middlewareString)
        }
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        let safeSendableText = SafeSendable(value: text)

        Task {
            guard case .text = info.content else { return }
            
            let middlewareString = AttributedTextConverter.asMiddleware(attributedText: safeSendableText.value)
            
            await EventsBunch(
                contextId: document.objectId,
                dataSourceUpdateEvents: [.setText(blockId: info.id, text: middlewareString)]
            ).send()
            
            try await service.setText(contextId: document.objectId, blockId: info.id, middlewareString: middlewareString)
        }
    }
    
    // MARK: - Public methods
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: String) {
        
        Task {
            
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setLoadingState(blockId: blockId)]
            ).send()
            
            try await fileService.uploadDataAt(source: uploadingSource, contextID: document.objectId, blockID: blockId)
        }

        AnytypeAnalytics.instance().logUploadMedia(type: type.asFileBlockContentType)
    }
    
    func uploadFileAt(localPath: String, blockId: String) {
        AnytypeAnalytics.instance().logUploadMedia(type: .file)
        
        Task {
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setLoadingState(blockId: blockId)]
            ).send()
            
            try await upload(blockId: blockId, filePath: localPath)
        }
    }
    
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> String? {
        guard let info = document.infoContainer.get(id: targetId) else { return nil }
        var position: BlockPosition
        if case .text(let blockText) = info.content, blockText.text.isEmpty {
            position = .replace
        } else {
            position = .bottom
        }
        return try await service.createPage(targetId: targetId, spaceId: spaceId, typeUniqueKey: typeUniqueKey, position: position, templateId: templateId)
    }

    func createTable(
        blockId: String,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeSendable<NSAttributedString?>
    ) async throws -> String {
        guard let isTextAndEmpty = blockText.value?.string.isEmpty
                ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return "" }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : .bottom

        AnytypeAnalytics.instance().logCreateBlock(type: TableBlockType.simpleTableBlock.rawValue)
        
        return try await blockTableService.createTable(
            contextId: document.objectId,
            targetId: blockId,
            position: position,
            rowsCount: rowsCount,
            columnsCount: columnsCount
        )
    }


    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString?, position: BlockPosition?) {
        guard type != .smartblock(.page) else {
            anytypeAssertionFailure("Use createPage func instead")
            return
        }
            
        guard let newBlock = BlockBuilder.createNewBlock(type: type) else { return }

        guard let isTextAndEmpty = blockText?.string.isEmpty
            ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : (position ?? .bottom)
        
        AnytypeAnalytics.instance().logCreateBlock(type: newBlock.content.type)
        service.add(info: newBlock, targetBlockId: blockId, position: position)
    }

    func selectBlock(info: BlockInformation) {
        blockSelectionHandler?.didSelectEditingState(info: info)
    }

    func createAndFetchBookmark(
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) {
        service.createAndFetchBookmark(
            contextID: document.objectId,
            targetID: targetID,
            position: position,
            url: url
        )
    }

    func setAppearance(blockId: String, appearance: BlockLink.Appearance) {
        Task {
            try await blockService.setLinkAppearance(objectId: document.objectId, blockIds: [blockId], appearance: appearance)
        }
    }
}
