import Foundation

protocol AddNewRelationCoordinatorAssemblyProtocol {
    func make() -> AddNewRelationCoordinatorProtocol
}

final class AddNewRelationCoordinatorAssembly: AddNewRelationCoordinatorAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let modulesDI: ModulesDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol, modulesDI: ModulesDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
        self.modulesDI = modulesDI
    }
    
    func make() -> AddNewRelationCoordinatorProtocol {
        return AddNewRelationCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            newRelationModuleAssembly: modulesDI.newRelation()
        )
    }
}
