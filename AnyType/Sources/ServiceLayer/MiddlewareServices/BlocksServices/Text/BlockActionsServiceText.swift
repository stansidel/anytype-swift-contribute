import Foundation
import Combine
import UIKit
import ProtobufMessages
import BlocksModels


private extension BlockActionsServiceText {
    enum PossibleError: Error {
        case setStyleActionStyleConversionHasFailed
        case setAlignmentActionAlignmentConversionHasFailed
        case splitActionStyleConversionHasFailed
    }
}

final class BlockActionsServiceText: BlockActionsServiceTextProtocol {    
    @discardableResult
    func setText(contextID: String, blockID: String, attributedString: NSAttributedString) -> AnyPublisher<Void, Error> {
        let middlewareString = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asMiddleware(attributedText: attributedString)
        return Anytype_Rpc.Block.Set.Text.Text.Service
            .invoke(contextID: contextID, blockID: blockID, text: middlewareString.text, marks: middlewareString.marks, queue: .global())
            .successToVoid()
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    // MARK: SetStyle
    func setStyle(contextID: BlockId, blockID: BlockId, style: Style) -> AnyPublisher<ServiceSuccess, Error> {
        let style = BlocksModelsParserTextContentTypeConverter.asMiddleware(style)
        return setStyle(contextID: contextID, blockID: blockID, style: style)
    }
    private func setStyle(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Set.Text.Style.Service.invoke(contextID: contextID, blockID: blockID, style: style).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    // MARK: SetForegroundColor
    func setForegroundColor(contextID: String, blockID: String, color: String) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextID, blockID: blockID, color: color)
            .successToVoid().subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    // MARK: SetAlignment
    func setAlignment(contextID: String, blockIds: [String], alignment: NSTextAlignment) -> AnyPublisher<Void, Error> {
        let ourAlignment = alignment.asBlockInformationAlignment
        guard let middlewareAlignment = ourAlignment.flatMap(BlocksModelsParserCommonAlignmentConverter.asMiddleware) else {
            return Fail.init(error: PossibleError.setAlignmentActionAlignmentConversionHasFailed).eraseToAnyPublisher()
        }
        return setAlignment(contextID: contextID, blockIds: blockIds, align: middlewareAlignment)
    }

    private func setAlignment(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    // MARK: Split
    func split(contextID: BlockId, blockID: BlockId, range: NSRange, style: Style) -> AnyPublisher<ServiceSuccess, Error> {
        let style = BlocksModelsParserTextContentTypeConverter.asMiddleware(style)
        let middlewareRange = MiddlewareModelsModule.Parsers.Text.AttributedText.RangeConverter.asMiddleware(range)
        return split(contextID: contextID, blockID: blockID, range: middlewareRange, style: style)
    }
    private func split(contextID: String, blockID: String, range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: range, style: style, mode: .bottom, queue: .global()).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    // MARK: Merge
    func merge(contextID: BlockId, firstBlockID: BlockId, secondBlockID: BlockId) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Merge.Service.invoke(
            contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID, queue: .global()
        )    
        .map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    // MARK: Checked
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Set.Text.Checked.Service.invoke(
            contextID: contextId,
            blockID: blockId,
            checked: newValue,
            queue: .global()
        )
            .map(\.event)
            .map(ServiceSuccess.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
