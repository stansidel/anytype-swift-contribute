import AnytypeCore
import BlocksModels
import Foundation

final class MarkupViewModel {
    
    var blockInformation: BlockInformation? {
        didSet {
            guard case let .text(textBlock) = blockInformation?.content else { return }
            anytypeText = AttributedTextConverter.asModel(
                text: textBlock.text,
                marks: textBlock.marks,
                style: textBlock.contentType,
                detailsStorage: detailsStorage
            )
            displayCurrentState()
        }
    }
    weak var view: MarkupViewProtocol?
    private let actionHandler: BlockActionHandlerProtocol
    private let detailsStorage: ObjectDetailsStorageProtocol

    private var selectedRange: MarkupRange?
    private var anytypeText: UIKitAnytypeText?
    
    init(actionHandler: BlockActionHandlerProtocol, detailsStorage: ObjectDetailsStorageProtocol) {
        self.actionHandler = actionHandler
        self.detailsStorage = detailsStorage
    }
    
    func setRange(_ range: MarkupRange) {
        selectedRange = range
        displayCurrentState()
    }
    
    func removeInformationAndDismiss() {
        blockInformation = nil
        view?.dismiss()
    }
    
    private func displayCurrentState() {
        guard let blockInformation = blockInformation,
              case let .text(textContent) = blockInformation.content,
              let range = selectedRange,
              let anytypeText = anytypeText else {
            return
        }
        let displayState = textAttributes(
            anytypeText: anytypeText,
            from: textContent,
            range: range.range(for: anytypeText.attrString),
            alignment: blockInformation.alignment
        )
        view?.setMarkupState(displayState)
    }
    
    private func setMarkup(
        markup: TextAttributesType, blockId: BlockId
    ) {
        actionHandler.toggleWholeBlockMarkup(markup, blockId: blockId)
    }
    
    private func textAttributes(
        anytypeText: UIKitAnytypeText,
        from content: BlockText,
        range: NSRange,
        alignment: LayoutAlignment
    ) -> AllMarkupsState {
        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        let markupCalculator = MarkupStateCalculator(
            attributedText: anytypeText.attrString,
            range: range,
            restrictions: restrictions,
            alignment: alignment.asNSTextAlignment
        )
        return AllMarkupsState(
            bold: markupCalculator.boldState(),
            italic: markupCalculator.italicState(),
            strikethrough: markupCalculator.strikethroughState(),
            codeStyle: markupCalculator.codeState(),
            alignment: markupCalculator.alignmentState(),
            url: nil
        )
    }
}

extension MarkupViewModel: MarkupViewModelProtocol {
    
    func handle(action: MarkupViewModelAction) {
        guard let blockInformation = blockInformation else {
            anytypeAssertionFailure("blockInformation must not be nil")
            return
        }
        guard case .text = blockInformation.content else {
            anytypeAssertionFailure("Expected text content type but got: \(blockInformation.content)")
            return
        }
        switch action {
        case let .selectAlignment(alignment):
            actionHandler.setAlignment(alignment, blockId: blockInformation.id)
        case let .toggleMarkup(markup):
            setMarkup(markup: markup, blockId: blockInformation.id)
        }
    }
    
    func viewLoaded() {
        displayCurrentState()
    }
}
