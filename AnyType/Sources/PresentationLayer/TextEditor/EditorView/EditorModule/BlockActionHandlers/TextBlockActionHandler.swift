//
//  TextBlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels
import os

private extension Logging.Categories {
    static let textEditorUserInteractorHandler: Self = "TextEditor.UserInteractionHandler"
}

final class TextBlockActionHandler {
    typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
    typealias ActionsPayloadTextViewTextView = ActionsPayload.TextBlocksViewsUserInteraction.Action.TextViewUserAction
    typealias DetailsInspector = TopLevel.AliasesMap.BlockUtilities.DetailsInspector

    private let service: BlockActionService
    private var indexWalker: LinearIndexWalker?

    init(service: BlockActionService, indexWalker: LinearIndexWalker?) {
        self.service = service
        self.indexWalker = indexWalker
    }

    func handlingTextViewAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionsPayloadTextViewTextView) {
        switch action {
        case let .keyboardAction(value): self.handlingKeyboardAction(block, value)
        default:
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.debug, log: logger, "Unexpected: %@", String(describing: action))
        }
    }

    func model(beforeModel: BlockActiveRecordModelProtocol, includeParent: Bool) -> BlockActiveRecordModelProtocol? {
        //        TopLevel.AliasesMap.BlockUtilities.IndexWalker.model(beforeModel: beforeModel, includeParent: includeParent)
        self.indexWalker?.renew()
        return self.indexWalker?.model(beforeModel: beforeModel, includeParent: includeParent)
    }

    private func handlingKeyboardAction(_ block: BlockActiveRecordModelProtocol, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            if DetailsInspector.kind(of: block.blockModel.information.id) == .title {
                switch keyAction {
                case .enter, .enterWithPayload, .enterAtBeginning:
                    let id = block.blockModel.information.id
                    let (blockId, _) = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.IdentifierBuilder.asDetails(id)
                    let block = block.container?.choose(by: blockId)
                    let parentId = block?.blockModel.information.id

                    if let information = BlockBuilder.createDefaultInformation(), let parentId = parentId {
                        if block?.childrenIds().isEmpty == true {
                            self.service.addChild(childBlock: information, parentBlockId: parentId)
                        }
                        else {
                            let first = block?.childrenIds().first
                            self.service.add(newBlock: information, afterBlockId: first ?? "", position: .top, shouldSetFocusOnUpdate: true)
                        }
                    }

                default: return
                }
                return
            }
            switch keyAction {
            // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
            case let .enterWithPayload(left, payload):
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if let oldText = left {
                        guard case let .text(text) = block.blockModel.information.content else {
                            assertionFailure("Only text block may send keyboard action")
                            return
                        }
                        self.service.split(block: block.blockModel.information,
                                           oldText: oldText,
                                           newBlockContentType: text.contentType,
                                           shouldSetFocusOnUpdate: true)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                    }
                }

            case let .enterAtBeginning(payload): // we should assure ourselves about type of block.
                /// TODO: Fix it in TextView API.
                /// If payload is empty, so, handle it as .enter ( or .enter at the end )
                if payload?.isEmpty == true {
                    self.handlingKeyboardAction(block, .pressKey(.enter))
                    return
                }
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if payload != nil, case let .text(text) = block.blockModel.information.content {
                        self.service.split(block: block.blockModel.information,
                                           oldText: "",
                                           newBlockContentType: text.contentType,
                                           shouldSetFocusOnUpdate: true)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                    }
                }

            case .enter:
                // BUSINESS LOGIC:
                // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
                switch block.blockModel.information.content {
                case let .text(value) where value.contentType.isList && value.attributedText.string == "":
                    // Turn Into empty text block.
                    if let newContentType = BlockBuilder.createContentType(block: block, action: action, textPayload: value.attributedText.string) {
                        /// TODO: Add focus on this block.
                        self.service.turnInto(block: block.blockModel.information, type: newContentType, shouldSetFocusOnUpdate: true)
                    }
                default:
                    if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: "") {
                        /// TODO:
                        /// Uncomment when you are ready.
                        //                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                        let logger = Logging.createLogger(category: .todo(.remove("Remove after refactoring of set focus.")))
                        os_log(.debug, log: logger, "We should not use self.service.split here. Instead, we should self.service.add block. It is possible to swap them only after set focus total cleanup. Redo it.")

                        switch block.blockModel.information.content {
                        case let .text(payload):
                            let isListAndNotToggle = payload.contentType.isListAndNotToggle
                            let isToggleAndOpen = payload.contentType == .toggle && block.isToggled
                            // In case of return was tapped in list block (for toggle it should be open)
                            // and this block has children, we will insert new child block at the beginning
                            // of children list, otherwise we will create new block under current block
                            let childrenIds = block.childrenIds()
                            switch (childrenIds.isEmpty, isToggleAndOpen, isListAndNotToggle) {
                            case (true, true, _):
                                self.service.addChild(childBlock: newBlock,
                                                      parentBlockId: block.blockModel.information.id)
                            case (false, true, _), (false, _, true):
                                let firstChildId = childrenIds[0]
                                self.service.add(newBlock: newBlock,
                                                 afterBlockId: firstChildId,
                                                 position: .top,
                                                 shouldSetFocusOnUpdate: true)
                            default:
                                let newContentType = payload.contentType.isList ? payload.contentType : .text
                                let oldText = payload.attributedText.string
                                self.service.split(block: block.blockModel.information,
                                                   oldText: oldText,
                                                   newBlockContentType: newContentType,
                                                   shouldSetFocusOnUpdate: true)
                            }
                        default: return
                        }

                    }
                }

            case .deleteWithPayload(_):
                // TODO: Add Index Walker
                // Add get previous block

                guard let previousModel = self.model(beforeModel: block, includeParent: true) else {
                    let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                    os_log(.debug, log: logger, "We can't find previous block to focus on at command .deleteWithPayload for block %@. Moving to .delete command.", block.blockModel.information.id)
                    self.handlingKeyboardAction(block, .pressKey(.delete))
                    return
                }

                let previousBlockId = previousModel.blockModel.information.id

                let position: EventListening.PackOfEvents.OurEvent.Focus.Payload.Position
                switch previousModel.blockModel.information.content {
                case let .text(value):
                    let length = value.attributedText.length
                    position = .at(length)
                default: position = .end
                }

                //                var newAttributedString: NSMutableAttributedString?
                //                switch (previousModel.blockModel.information.content, block.blockModel.information.content) {
                //                case let (.text(lhs), .text(rhs)):
                //                    let left = lhs.attributedText
                //                    newAttributedString = .init(attributedString: left)
                //                    let right = rhs.attributedText
                //                    newAttributedString?.append(right)
                //                default: break
                //                }

                //                let attributedString = newAttributedString

                self.service.merge(firstBlock: previousModel.blockModel.information, secondBlock: block.blockModel.information) { value in
                    .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        //                        .setText(.init(payload: .init(blockId: previousBlockId, attributedString: attributedString))),
                        .setTextMerge(.init(payload: .init(blockId: previousBlockId))),
                        .setFocus(.init(payload: .init(blockId: previousBlockId, position: position)))
                    ])
                }
                break

            case .delete:
                self.service.delete(block: block.blockModel.information) { value in
                    guard let previousModel = self.model(beforeModel: block, includeParent: true) else {
                        let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                        os_log(.debug, log: logger, "We can't find previous block to focus on at command .delete for block %@", block.blockModel.information.id)
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    let previousBlockId = previousModel.blockModel.information.id
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setFocus(.init(payload: .init(blockId: previousBlockId, position: .end)))
                    ])
                }
            }
        }
    }
}
