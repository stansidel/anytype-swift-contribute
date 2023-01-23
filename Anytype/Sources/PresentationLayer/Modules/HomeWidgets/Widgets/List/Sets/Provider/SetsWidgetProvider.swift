import Foundation
import SwiftUI
import BlocksModels

// TODO: Create common provider, provider assembly, output if all files will be the same
final class SetsWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let setsWidgetModuleAssembly: SetsWidgetModuleAssemblyProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        setsWidgetModuleAssembly: SetsWidgetModuleAssemblyProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.setsWidgetModuleAssembly = setsWidgetModuleAssembly
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return setsWidgetModuleAssembly.make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            output: output
        )
    }()
    
    var componentId: String {
        return widgetBlockId
    }
}
