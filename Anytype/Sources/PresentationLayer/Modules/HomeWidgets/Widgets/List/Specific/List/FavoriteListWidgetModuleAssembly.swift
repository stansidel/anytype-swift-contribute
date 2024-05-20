import Foundation
import SwiftUI

final class FavoriteListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - HomeWidgetCommonAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let data =  WidgetSubmoduleData(widgetBlockId: widgetBlockId, widgetObject: widgetObject, stateManager: stateManager, output: output)
        let model = FavoriteWidgetInternalViewModel(data: data)
        
        return ListWidgetView(
            data: data,
            style: .list,
            internalModel: model,
            internalHeaderModel: nil
        ).eraseToAnyView()
    }
}
