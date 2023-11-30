import FloatingPanel
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore
import Combine

@MainActor
final class SetRelationsViewModel: ObservableObject {
    @Published var view: DataviewView = .empty
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let dataviewService: DataviewServiceProtocol
    
    private weak var output: SetRelationsCoordinatorOutput?
    
    private var cancellable: Cancellable?
    
    var relations: [SetViewSettingsRelation] {
        setDocument.sortedRelations(for: viewId).map { relation in
            SetViewSettingsRelation(
                id: relation.id,
                image: relation.relationDetails.format.iconAsset,
                title: relation.relationDetails.name,
                isOn: relation.option.isVisible,
                canBeRemovedFromObject: relation.relationDetails.canBeRemovedFromObject,
                onChange: { [weak self] isVisible in
                    self?.onRelationVisibleChange(relation, isVisible: isVisible)
                }
            )
        }
    }
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        dataviewService: DataviewServiceProtocol,
        output: SetRelationsCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataviewService = dataviewService
        self.output = output
        self.setup()
    }
    
    func deleteRelations(indexes: IndexSet) {
        indexes.forEach { index in
            guard let relation = setDocument.sortedRelations(for: viewId)[safe: index] else {
                anytypeAssertionFailure("No relation to delete", info: ["index": "\(index)"])
                return
            }
            Task {
                let key = relation.relationDetails.key
                try await dataviewService.deleteRelation(relationKey: key)
                try await dataviewService.removeViewRelations([key], viewId: viewId)
            }
        }
    }
    
    func moveRelation(from: IndexSet, to: Int) {
        from.forEach { [weak self] sortedRelationsFromIndex in
            guard let self, sortedRelationsFromIndex != to else { return }
            
            let sortedRelations = setDocument.sortedRelations(for: viewId)
            let relationFrom = sortedRelations[sortedRelationsFromIndex]
            let sortedRelationsToIndex = to > sortedRelationsFromIndex ? to - 1 : to // map insert index to item index
            let relationTo = sortedRelations[sortedRelationsToIndex]
            let options = view.options
            
            // index in all options array (includes hidden options)
            guard let indexFrom = options.index(of: relationFrom) else {
                anytypeAssertionFailure("No from relation for move", info: ["key": relationFrom.relationDetails.key])
                return
            }
            guard let indexTo = options.index(of: relationTo) else {
                anytypeAssertionFailure("No to relation for move", info: ["key": relationTo.relationDetails.key])
                return
            }
            
            var newOptions = options
            newOptions.moveElement(from: indexFrom, to: indexTo)
            let keys = newOptions.map { $0.key }
            Task { [weak self] in
                guard let self else { return }
                try await dataviewService.sortViewRelations(keys, viewId: viewId)
            }
        }
    }
    
    func showAddNewRelationView() {
        output?.onAddButtonTap { relation, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .dataview)
        }
    }
    
    private func setup() {
        cancellable = setDocument.syncPublisher.sink {  [weak self] in
            guard let self else { return }
            view = setDocument.view(by: viewId)
        }
    }
    
    private func onRelationVisibleChange(_ relation: SetRelation, isVisible: Bool) {
        Task {
            let newOption = relation.option.updated(isVisible: isVisible).asMiddleware
            try await dataviewService.replaceViewRelation(
                relation.option.key,
                with: newOption,
                viewId: viewId
            )
        }
    }
}
