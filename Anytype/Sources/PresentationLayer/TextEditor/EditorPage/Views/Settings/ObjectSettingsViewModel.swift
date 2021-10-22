import Foundation
import Combine
import BlocksModels

final class ObjectSettingsViewModel: ObservableObject {
    
    @Published private(set) var details: ObjectDetails = ObjectDetails(id: "", values: [:])
    var settings: [ObjectSetting] {
        if details.type == ObjectTypeProvider.myProfileURL {
            return ObjectSetting.allCases.filter { $0 != .layout }
        }
        
        switch details.layout {
        case .basic:
            return ObjectSetting.allCases
        case .profile:
            return ObjectSetting.allCases
        case .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        }
    }

    let objectActionsViewModel: ObjectActionsViewModel

    let iconPickerViewModel: ObjectIconPickerViewModel
    let coverPickerViewModel: ObjectCoverPickerViewModel
    let layoutPickerViewModel: ObjectLayoutPickerViewModel
    
    private let objectDetailsService: ObjectDetailsService
    
    init(objectId: String, objectDetailsService: ObjectDetailsService) {
        self.objectDetailsService = objectDetailsService

        self.iconPickerViewModel = ObjectIconPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsService: objectDetailsService
        )
        self.coverPickerViewModel = ObjectCoverPickerViewModel(
            fileService: BlockActionsServiceFile(),
            detailsService: objectDetailsService
        )
        
        self.layoutPickerViewModel = ObjectLayoutPickerViewModel(
            detailsService: objectDetailsService
        )

        self.objectActionsViewModel = ObjectActionsViewModel(objectId: objectId)
    }
    
    func update(with details: ObjectDetails) {
        objectActionsViewModel.details = details
        self.details = details
        iconPickerViewModel.details = details
        layoutPickerViewModel.details = details
    }
}
