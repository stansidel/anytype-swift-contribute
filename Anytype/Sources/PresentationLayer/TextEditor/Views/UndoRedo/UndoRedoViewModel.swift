import UIKit
import AnytypeCore

final class UndoRedoViewModel: ObservableObject {
    struct ButtonModel: Identifiable {
        let id: String
        let title: String
        let imageAsset: ImageAsset
        let action: () -> Void
    }

    var onErrorHandler: RoutingAction<String>?
    
    lazy private(set) var buttonModels = buildButtonModels()

    private let objectId: String
    private let objectActionsService: ObjectActionsServiceProtocol

    init(
        objectId: String,
        objectActionsService: ObjectActionsServiceProtocol
    ) {
        self.objectId = objectId
        self.objectActionsService = objectActionsService
    }

    func undo() {
        AnytypeAnalytics.instance().logUndo()
        do {
            try objectActionsService.undo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            onErrorHandler?(error.message)
        } catch {
            anytypeAssertionFailure("Unknown error")
        }
    }

    func redo() {
        AnytypeAnalytics.instance().logRedo()
        do {
            try objectActionsService.redo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            onErrorHandler?(error.message)
        } catch {
            anytypeAssertionFailure("Unknown error")
        }
    }

    private func buildButtonModels() -> [ButtonModel] {
        [
            .init(
                id: "undo",
                title: "Undo",
                imageAsset: .X32.Undo.undo,
                action: { [weak self] in self?.undo() }
            ),
            .init(
                id: "redo",
                title: "Redo",
                imageAsset: .X32.Undo.redo,
                action: { [weak self] in self?.redo() }
            )
        ]
    }
}
