import UIKit

enum BlocksFileEmptyViewState {
    case `default`
    case uploading
    case error
}

struct BlocksFileEmptyViewConfiguration: AnytypeBlockContentConfigurationProtocol {
    let image: UIImage
    let text: String
    let state: BlocksFileEmptyViewState
    var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        BlocksFileEmptyView(configuration: self)
    }
}
