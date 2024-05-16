import Foundation
import UIKit


protocol UIHelpersDIProtocol {
    var keyboardListener: KeyboardHeightListener { get }
    
    func toastPresenter() -> ToastPresenterProtocol
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol
    func viewControllerProvider() -> ViewControllerProviderProtocol
    func commonNavigationContext() -> NavigationContextProtocol
    func urlOpener() -> URLOpenerProtocol
}

final class UIHelpersDI: UIHelpersDIProtocol {
    
    private let _viewControllerProvider: ViewControllerProviderProtocol
    private let serviceLocator: ServiceLocator
    
    init(viewControllerProvider: ViewControllerProviderProtocol, serviceLocator: ServiceLocator) {
        self._viewControllerProvider = viewControllerProvider
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - UIHelpersDIProtocol
    let keyboardListener = KeyboardHeightListener()
    
    func toastPresenter() -> ToastPresenterProtocol {
        toastPresenter(using: nil)
    }
    
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol {
        ToastPresenter(
            viewControllerProvider: viewControllerProvider(),
            containerViewController: containerViewController,
            keyboardHeightListener: KeyboardHeightListener()
        )
    }
    
    func viewControllerProvider() -> ViewControllerProviderProtocol {
        return _viewControllerProvider
    }
    
    func commonNavigationContext() -> NavigationContextProtocol {
        NavigationContext(window: viewControllerProvider().window)
    }
    
    func urlOpener() -> URLOpenerProtocol {
        URLOpener(navigationContext: commonNavigationContext())
    }
}
