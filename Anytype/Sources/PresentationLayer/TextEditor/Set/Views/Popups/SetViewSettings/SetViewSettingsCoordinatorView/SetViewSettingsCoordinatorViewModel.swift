import SwiftUI
import Services

@MainActor
protocol SetViewSettingsCoordinatorOutput: AnyObject {
    func onDefaultObjectTap()
    func onDefaultTemplateTap()
    func onLayoutTap()
    func onRelationsTap()
    func onFiltersTap()
    func onSortsTap()
}

@MainActor
final class SetViewSettingsCoordinatorViewModel: ObservableObject, SetViewSettingsCoordinatorOutput {
    @Published var showLayouts = false
    @Published var showRelations = false
    @Published var showFilters = false
    @Published var showSorts = false
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let mode: SetViewSettingsMode
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    private let setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol
    private let setLayoutSettingsCoordinatorAssembly: SetLayoutSettingsCoordinatorAssemblyProtocol
    private let setRelationsCoordinatorAssembly: SetRelationsCoordinatorAssemblyProtocol
    private let setFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol
    private let setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol
    private let objectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        setViewSettingsListModuleAssembly: SetViewSettingsListModuleAssemblyProtocol,
        setLayoutSettingsCoordinatorAssembly: SetLayoutSettingsCoordinatorAssemblyProtocol,
        setRelationsCoordinatorAssembly: SetRelationsCoordinatorAssemblyProtocol,
        setFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol,
        setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol,
        objectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.mode = mode
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
        self.setViewSettingsListModuleAssembly = setViewSettingsListModuleAssembly
        self.setLayoutSettingsCoordinatorAssembly = setLayoutSettingsCoordinatorAssembly
        self.setRelationsCoordinatorAssembly = setRelationsCoordinatorAssembly
        self.setFiltersListCoordinatorAssembly = setFiltersListCoordinatorAssembly
        self.setSortsListCoordinatorAssembly = setSortsListCoordinatorAssembly
        self.objectCreationSettingsCoordinator = objectCreationSettingsCoordinator
    }
    
    func list() -> AnyView {
        setViewSettingsListModuleAssembly.make(
            setDocument: setDocument,
            viewId: viewId,
            mode: mode,
            output: self
        )
    }
    
    // MARK: - SetViewSettingsCoordinatorOutput
    
    // MARK: - Default object creation settings
    
    func onDefaultObjectTap() {
        startObjectCreationSettings()
    }
    
    func onDefaultTemplateTap() {
        startObjectCreationSettings()
    }
    
    private func startObjectCreationSettings() {
        objectCreationSettingsCoordinator.showSetObjectCreationSettings(
            setDocument: setDocument,
            viewId: viewId,
            onTemplateSelection: { _ in }
        )
    }
    
    // MARK: - Layout
    
    func onLayoutTap() {
        showLayouts.toggle()
    }
    
    func setLayoutSettings() -> AnyView {
        setLayoutSettingsCoordinatorAssembly.make(
            setDocument: setDocument,
            viewId: viewId
        )
    }
    
    // MARK: - Relations
    
    func onRelationsTap() {
        showRelations.toggle()
    }
    
    func relationsList() -> AnyView {
        setRelationsCoordinatorAssembly.make(
            with: setDocument,
            viewId: viewId
        )
    }
    
    // MARK: - Filters
    
    func onFiltersTap() {
        showFilters.toggle()
    }
    
    func setFiltersList() -> AnyView {
        setFiltersListCoordinatorAssembly.make(
            with: setDocument,
            viewId: viewId,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    // MARK: - Sorts
    
    func onSortsTap() {
        showSorts.toggle()
    }
    
    func setSortsList() -> AnyView {
        setSortsListCoordinatorAssembly.make(
            with: setDocument,
            viewId: viewId
        )
    }
}

extension SetViewSettingsCoordinatorViewModel {
    struct TypesSearchData: Identifiable {
        let id = UUID()
        let completion: (BlockId) -> Void
    }
}
