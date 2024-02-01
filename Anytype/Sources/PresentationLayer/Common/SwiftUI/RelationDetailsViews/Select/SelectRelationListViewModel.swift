import Combine
import Foundation
import Services
import SwiftUI

@MainActor
final class SelectRelationListViewModel: ObservableObject {
    
    @Published var selectedOptionId: String?
    @Published var options: [SelectRelationOption] = []
    @Published var isEmpty = false
    @Published var searchText = ""
        
    let configuration: RelationModuleConfiguration
    
    private let relationsService: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    
    private weak var output: SelectRelationListModuleOutput?
    
    init(
        configuration: RelationModuleConfiguration,
        selectedOptionId: String?,
        output: SelectRelationListModuleOutput?,
        relationsService: RelationsServiceProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.configuration = configuration
        self.selectedOptionId = selectedOptionId
        self.output = output
        self.relationsService = relationsService
        self.searchService = searchService
    }
    
    func onAppear() {
        searchTextChanged()
    }

    func onClear() {
        Task {
            selectedOptionId = nil
            try await relationsService.updateRelation(relationKey: configuration.relationKey, value: nil)
            logChanges()
        }
    }
    
    func onCreate(with title: String?, color: Color? = nil) {
        output?.onCreateTap(text: title, color: color, completion: { [weak self] option in
            self?.updateListOnCreate(with: option.id)
        })
    }
    
    func onOptionEdit(_ option: SelectRelationOption) {
        output?.onEditTap(option: option, completion: { [weak self] option in
            guard let self else { return }
            if let index = options.firstIndex(where: { $0.id == option.id }) {
                options[index] = option
            }
        })
    }
    
    func onOptionDuplicate(_ option: SelectRelationOption) {
        onCreate(with: option.text, color: option.color)
    }
    
    func onOptionDelete(with indexSet: IndexSet) {
        indexSet.forEach { deleteIndex in
            guard deleteIndex < options.count else { return }
            let optionToDelete = options[deleteIndex]
            onOptionDelete(optionToDelete)
        }
    }
    
    func onOptionDelete(_ option: SelectRelationOption) {
        output?.onDeleteTap { [weak self] isSuccess in
            guard let self else { return }
            if isSuccess {
                removeRelationOption(option)
            } else {
                options = options
            }            
        }
    }
    
    func optionSelected(_ optionId: String, dismiss: Bool = true) {
        Task {
            try await optionSelectedAsync(optionId, dismiss: dismiss)
        }
    }
    
    func searchTextChanged(_ text: String = "") {
        Task {
            try await searchTextChangedAsync(text)
        }
    }
    
    private func optionSelectedAsync(_ optionId: String, dismiss: Bool = true) async throws {
        try await relationsService.updateRelation(relationKey: configuration.relationKey, value: optionId.protobufValue)
        selectedOptionId = optionId
        logChanges()
        if dismiss {
            output?.onClose()
        }
    }
    
    private func searchTextChangedAsync(_ text: String = "") async throws {
        let rawOptions = try await searchService.searchRelationOptions(
            text: text,
            relationKey: configuration.relationKey,
            excludedObjectIds: [],
            spaceId: configuration.spaceId
        ).map { SelectRelationOption(relation: $0) }
        
        if configuration.isEditable {
            options = rawOptions.reordered(
                by: [selectedOptionId].compactMap { $0 }
            ) { $0.id }
        } else {
            options = options.filter { $0.id == selectedOptionId }
        }
        
        setEmptyIfNeeded()
    }
    
    private func updateListOnCreate(with optionId: String) {
        Task {
            searchText = ""
            try await optionSelectedAsync(optionId, dismiss: false)
            try await searchTextChangedAsync()
        }
    }
    
    private func setEmptyIfNeeded() {
        isEmpty = options.isEmpty && searchText.isEmpty
    }
    
    private func removeRelationOption(_ option: SelectRelationOption) {
        Task {
            try await relationsService.removeRelationOptions(ids: [option.id])
            if let index = options.firstIndex(of: option) {
                options.remove(at: index)
            }
            if selectedOptionId == option.id {
                onClear()
            }
            setEmptyIfNeeded()
        }
    }
    
    private func logChanges() {
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOptionId.isNil, type: configuration.analyticsType)
    }
}
